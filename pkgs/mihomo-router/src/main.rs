//! Long-running Mihomo controller: verifies real exit countries through four
//! fixed probe listeners and picks FOREIGN-OUT via the REST API.
mod api;
mod node;
mod probe;

use std::collections::BTreeMap;
use std::fs;
use std::path::PathBuf;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

use api::{Api, Provider, Proxy};
use clap::Parser;
use node::{Cache, Entry};
use sha2::{Digest, Sha256};
use tokio::sync::Semaphore;
use tokio::task::JoinSet;
use tracing::{debug, error, info, warn};

const OUTBOUND: &str = "FOREIGN-OUT";
/// First probe listener port; listeners are PROBE_PORT..PROBE_PORT+LANES-1.
const PROBE_PORT: u16 = 17800;
/// Probe groups PROBE-0..PROBE-{LANES-1} with matching fixed listeners.
const LANES: usize = 4;
const LATENCY_TOLERANCE_MS: u32 = 50;

#[derive(Parser)]
#[command(about = "Mihomo controller that verifies the real exit country")]
struct Args {
    /// Mihomo REST API base (loopback only).
    #[arg(long, default_value = "http://127.0.0.1:9090")]
    api: String,
    /// File holding the API secret; omit when mihomo has none.
    #[arg(long)]
    token_file: Option<PathBuf>,
    /// proxy-provider name.
    #[arg(long, default_value = "vless")]
    provider: String,
    /// State directory (verification cache).
    #[arg(long)]
    state: PathBuf,
    /// Seconds between reconciliation passes.
    #[arg(long, default_value_t = 60)]
    interval: u64,
}

pub fn now() -> f64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs_f64()
}

/// Provider fingerprint. The refresh timestamp is part of it because the API
/// never exposes full credentials: any refresh invalidates prior trust.
fn revision(p: &Provider) -> String {
    let mut names: Vec<&str> = p.proxies.iter().map(|n| n.name.as_str()).collect();
    names.sort_unstable();
    let mut hasher = Sha256::new();
    hasher.update(p.updated_at.as_bytes());
    for name in names {
        hasher.update(b"\0");
        hasher.update(name.as_bytes());
    }
    format!("{:x}", hasher.finalize())
}

fn candidates(p: &Provider) -> Vec<Proxy> {
    let mut out: Vec<Proxy> = vec![];
    for proxy in &p.proxies {
        if proxy.name.is_empty() || out.iter().any(|n| n.name == proxy.name) {
            continue;
        }
        out.push(proxy.clone());
    }
    out.sort_by(|a, b| a.name.cmp(&b.name));
    out
}

fn rejected(reason: String) -> Entry {
    let t = now();
    Entry {
        verdict: "unverified".into(),
        reason,
        checked_at: t,
        expires_at: t + node::FAILURE_TTL_SECS as f64,
        exit_ips: vec![],
        countries: vec![],
    }
}

/// Probe one batch of nodes, one node per lane. The lane's probe group is
/// selected explicitly and confirmed before probing, so a verdict always
/// belongs to the node that was actually measured.
async fn probe_batch(api: &Api, nodes: &[Proxy]) -> Vec<(String, Entry)> {
    let mut jobs = JoinSet::new();
    for (lane, proxy) in nodes.iter().enumerate() {
        let api = api.clone();
        let name = proxy.name.clone();
        jobs.spawn(async move {
            let group = format!("PROBE-{lane}");
            let port = PROBE_PORT + lane as u16;
            debug!("lane {lane}: {name:?} via {group} on 127.0.0.1:{port}");
            let started = Instant::now();
            let entry = match api.select(&group, &name).await {
                Err(e) => rejected(format!("probe selector: {e}")),
                Ok(()) => probe::verify(port).await,
            };
            debug!(
                "lane {lane}: {name:?} measured in {:?}: {} ({})",
                started.elapsed(),
                entry.verdict,
                entry.reason
            );
            // Never leave a probe lane pinned to a node after measuring it.
            if let Err(e) = api.select(&group, "REJECT").await {
                warn!("could not reset probe lane {group}: {e}");
            }
            (name, entry)
        });
    }
    let mut out = vec![];
    while let Some(result) = jobs.join_next().await {
        match result {
            Ok(item) => out.push(item),
            Err(e) => error!("probe worker crashed: {e}"),
        }
    }
    out
}

/// Select the lowest-latency eligible node; keep the current one when it is
/// still eligible and within the tolerance band.
async fn choose(api: &Api, provider: &str, nodes: &[Proxy], cache: &mut Cache) -> Result<(), String> {
    let t = now();
    let eligible: Vec<String> = nodes
        .iter()
        .filter(|p| cache.entries.get(&p.name).is_some_and(|e| e.eligible(t)))
        .map(|p| p.name.clone())
        .collect();
    if eligible.is_empty() {
        if api.group(OUTBOUND).await?.now != "REJECT" {
            api.select(OUTBOUND, "REJECT").await?;
            warn!("no eligible node: {OUTBOUND} -> REJECT");
        }
        return Ok(());
    }
    debug!("{} eligible nodes: {:?}", eligible.len(), eligible);

    let gate = std::sync::Arc::new(Semaphore::new(8));
    let mut tasks = JoinSet::new();
    for name in eligible {
        let gate = gate.clone();
        let api = api.clone();
        let provider = provider.to_string();
        tasks.spawn(async move {
            let _permit = gate.acquire().await.ok();
            let delay = api.delay(&provider, &name).await;
            (name, delay)
        });
    }
    let mut delays = BTreeMap::new();
    while let Some(result) = tasks.join_next().await {
        match result {
            Ok((name, Ok(delay))) => {
                delays.insert(name, delay);
            }
            Ok((name, Err(e))) => {
                // Do not leave a presently unreachable node eligible.
                cache.entries.insert(name, rejected(format!("latency check: {e}")));
            }
            Err(e) => error!("latency task failed: {e}"),
        }
    }

    let selected = api.group(OUTBOUND).await?.now;
    debug!("latencies: {:?}", delays);
    let Some((best, best_delay)) = delays.iter().min_by_key(|(_, d)| **d) else {
        warn!("no latency-eligible node: {OUTBOUND} -> REJECT");
        api.select(OUTBOUND, "REJECT").await?;
        return Ok(());
    };
    let next = match delays.get(&selected) {
        Some(&current) if current <= best_delay.saturating_add(LATENCY_TOLERANCE_MS) => {
            debug!("keeping {selected:?} ({current} ms) over best {best:?} ({best_delay} ms)");
            selected.clone()
        }
        _ => best.clone(),
    };
    if next != selected {
        api.select(OUTBOUND, &next).await?;
        info!("{OUTBOUND} -> {next} (best {best_delay} ms)");
    }
    Ok(())
}

async fn pass(api: &Api, args: &Args, cache: &mut Cache) -> Result<(), String> {
    let provider = api.provider(&args.provider).await?;
    let nodes = candidates(&provider);
    let stamp = revision(&provider);
    debug!(
        "provider {} updatedAt={} revision={}",
        args.provider,
        provider.updated_at,
        &stamp[..8]
    );
    let cache_path = args.state.join("cache.json");

    if stamp != cache.revision {
        // Provider refreshed: nothing measured against the old nodes is trusted.
        warn!("provider refreshed: dropping all verdicts and selecting REJECT");
        api.select(OUTBOUND, "REJECT").await?;
        cache.entries.clear();
        cache.revision = stamp.clone();
        node::save(&cache_path, cache)?;
    }

    // The current selection must still exist in the provider and stay verified.
    let current = api.group(OUTBOUND).await?.now;
    debug!("{OUTBOUND} currently {current:?}");
    if current != "REJECT"
        && !cache.entries.get(&current).is_some_and(|e| {
            e.eligible(now()) && nodes.iter().any(|p| p.name == current)
        })
    {
        warn!("dropping selection {current:?}: not verified or no longer in the provider");
        api.select(OUTBOUND, "REJECT").await?;
    }

    let t = now();
    let stale: Vec<Proxy> = nodes
        .iter()
        .filter(|p| !cache.entries.get(&p.name).is_some_and(|e| e.eligible(t)))
        .cloned()
        .collect();
    info!("{} nodes, {} need exit checks", nodes.len(), stale.len());

    for (n, batch) in stale.chunks(LANES).enumerate() {
        debug!(
            "batch {}/{}: {} nodes",
            n + 1,
            stale.len().div_ceil(LANES),
            batch.len()
        );
        for (name, entry) in probe_batch(api, batch).await {
            info!("exit check {name:?}: {} ({})", entry.verdict, entry.reason);
            cache.entries.insert(name, entry);
        }
        node::save(&cache_path, cache)?;
        // Drop verdicts measured while the provider changed underneath us.
        if revision(&api.provider(&args.provider).await?) != stamp {
            api.select(OUTBOUND, "REJECT").await?;
            cache.entries.clear();
            cache.revision.clear();
            node::save(&cache_path, cache)?;
            return Err("provider changed mid-scan; verdicts discarded".into());
        }
    }

    choose(api, &args.provider, &nodes, cache).await?;
    node::save(&cache_path, cache)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();
    fs::create_dir_all(&args.state)?;
    let token = match &args.token_file {
        Some(path) => Some(fs::read_to_string(path)?.trim().to_owned()),
        None => None,
    };
    if token.as_deref() == Some("") {
        return Err("empty Mihomo API secret".into());
    }
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("mihomo_router=debug")),
        )
        .init();
    info!(
        "starting: api={} provider={} state={} interval={}s lanes={} ports={}..{}",
        args.api,
        args.provider,
        args.state.display(),
        args.interval,
        LANES,
        PROBE_PORT,
        PROBE_PORT + LANES as u16 - 1
    );
    let api = Api::new(&args.api, token)?;
    let mut cache = node::load(&args.state.join("cache.json"));
    loop {
        let started = Instant::now();
        match pass(&api, &args, &mut cache).await {
            Ok(()) => debug!("pass finished in {:?}", started.elapsed()),
            Err(e) => error!("controller pass failed after {:?}: {e}", started.elapsed()),
        }
        tokio::time::sleep(Duration::from_secs(args.interval)).await;
    }
}
