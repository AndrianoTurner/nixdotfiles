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
use node::{Cache, Entry, RANK_TTL_SECS};
use sha2::{Digest, Sha256};
use tokio::sync::Semaphore;
use tokio::task::JoinSet;
use tracing::{debug, error, info, warn};

const OUTBOUND: &str = "FOREIGN-OUT";
const LATENCY_TOLERANCE_MS: u32 = 50;
/// Node names containing this (case-insensitive) are the metered fallback tier:
/// selectable even with a RU exit, but only when no other verified node works.
const RU_FALLBACK_MARKER: &str = "lte";

/// 0 = normal node, 1 = metered fallback. Selection tries the lowest tier
/// that has eligible nodes, so LTE is never used while the static line works.
fn tier(name: &str) -> u8 {
    u8::from(name.to_lowercase().contains(RU_FALLBACK_MARKER))
}

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
    /// Number of probe lanes; needs matching PROBE-0..N groups and listeners.
    #[arg(long, default_value_t = 4)]
    lanes: usize,
    /// First probe listener port; lane N listens on port + N.
    #[arg(long, default_value_t = 17800)]
    probe_port: u16,
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

fn rejected(prev_failures: u32, reason: String) -> Entry {
    let t = now();
    let failures = prev_failures.saturating_add(1);
    Entry {
        verdict: "unverified".into(),
        reason,
        checked_at: t,
        expires_at: t + Entry::failure_ttl(failures) as f64,
        exit_ips: vec![],
        countries: vec![],
        failures,
    }
}

/// Probe one batch of nodes, one node per lane. The lane's probe group is
/// selected explicitly and confirmed before probing, so a verdict always
/// belongs to the node that was actually measured.
async fn probe_batch(
    api: &Api,
    nodes: &[Proxy],
    probe_port: u16,
    entries: &BTreeMap<String, Entry>,
) -> Vec<(String, Entry)> {
    let mut jobs = JoinSet::new();
    for (lane, proxy) in nodes.iter().enumerate() {
        let api = api.clone();
        let name = proxy.name.clone();
        let prev_failures = entries.get(&proxy.name).map_or(0, |e| e.failures);
        jobs.spawn(async move {
            let group = format!("PROBE-{lane}");
            let port = probe_port + lane as u16;
            debug!("lane {lane}: {name:?} via {group} on 127.0.0.1:{port}");
            let started = Instant::now();
            let entry = match api.select(&group, &name).await {
                Err(e) => rejected(prev_failures, format!("probe selector: {e}")),
                Ok(()) => probe::verify(port, tier(&name) > 0, prev_failures).await,
            };
            debug!(
                "lane {lane}: {name:?} measured in {:?}: {} ({})",
                started.elapsed(),
                entry.verdict,
                entry.reason
            );
            // Never leave a probe lane pinned to a node after measuring it. The
            // reset needs no readback: the next probe selects and confirms its
            // own node anyway.
            if let Err(e) = api.set(&group, "REJECT").await {
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

/// Select the lowest-latency eligible node inside the lowest tier that has
/// any; keep the current one when it is in that tier and within the tolerance
/// band. Latency is only re-measured after a verdict changed or the ranking
/// went stale: each measurement is a full mihomo healthcheck.
async fn choose(
    api: &Api,
    provider: &str,
    nodes: &[Proxy],
    cache: &mut Cache,
    probed: bool,
) -> Result<(), String> {
    let t = now();
    let eligible: Vec<&Proxy> = nodes
        .iter()
        .filter(|p| cache.entries.get(&p.name).is_some_and(|e| e.eligible(t)))
        .collect();
    if eligible.is_empty() {
        if api.group(OUTBOUND).await?.now != "REJECT" {
            api.select(OUTBOUND, "REJECT").await?;
            warn!("no eligible node: {OUTBOUND} -> REJECT");
        }
        return Ok(());
    }
    // Tier 0 first: a working non-LTE node always beats the metered tier.
    let best_tier = eligible.iter().map(|p| tier(&p.name)).min().unwrap_or(0);
    let pool: Vec<String> = eligible
        .iter()
        .filter(|p| tier(&p.name) == best_tier)
        .map(|p| p.name.clone())
        .collect();
    debug!(
        "tier {best_tier}: {} of {} eligible nodes: {:?}",
        pool.len(),
        eligible.len(),
        pool
    );

    let ranked = !probed
        && t - cache.ranked_at < RANK_TTL_SECS as f64
        && pool.iter().all(|n| cache.delays.contains_key(n));
    let delays: BTreeMap<String, u32> = if ranked {
        debug!("tier {best_tier}: reusing cached latencies");
        pool.iter()
            .filter_map(|n| cache.delays.get(n).map(|d| (n.clone(), *d)))
            .collect()
    } else {
        let measured = rank(api, provider, &pool, cache).await;
        cache.delays = measured.clone();
        cache.ranked_at = now();
        measured
    };

    let selected = api.group(OUTBOUND).await?.now;
    debug!("latencies: {:?}", delays);
    let Some((best, best_delay)) = delays.iter().min_by_key(|(_, d)| **d) else {
        // shortcut: a tier whose nodes all fail the healthcheck goes REJECT for
        // one pass; their 600 s failure TTL drains it, so the pass after that
        // falls through to the tier below.
        warn!("no reachable node in tier {best_tier}: {OUTBOUND} -> REJECT");
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
        if best_tier > 0 {
            warn!("{OUTBOUND} -> {next} (metered fallback tier {best_tier}, {best_delay} ms)");
        } else {
            info!("{OUTBOUND} -> {next} (best {best_delay} ms)");
        }
    }
    Ok(())
}

/// Measure the latency of every pooled node through mihomo's own healthcheck.
async fn rank(
    api: &Api,
    provider: &str,
    pool: &[String],
    cache: &mut Cache,
) -> BTreeMap<String, u32> {
    let gate = std::sync::Arc::new(Semaphore::new(8));
    let mut tasks = JoinSet::new();
    for name in pool {
        let gate = gate.clone();
        let api = api.clone();
        let provider = provider.to_string();
        let name = name.clone();
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
                let prev = cache.entries.get(&name).map_or(0, |e| e.failures);
                cache
                    .entries
                    .insert(name, rejected(prev, format!("latency check: {e}")));
            }
            Err(e) => error!("latency task failed: {e}"),
        }
    }
    delays
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
        cache.delays.clear();
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

    for (n, batch) in stale.chunks(args.lanes).enumerate() {
        debug!(
            "batch {}/{}: {} nodes",
            n + 1,
            stale.len().div_ceil(args.lanes),
            batch.len()
        );
        for (name, entry) in probe_batch(api, batch, args.probe_port, &cache.entries).await {
            info!("exit check {name:?}: {} ({})", entry.verdict, entry.reason);
            cache.entries.insert(name, entry);
        }
        node::save(&cache_path, cache)?;
    }

    // One revision check for the whole scan: the provider blob is ~90 KB and
    // fully parsed, so checking it per batch costs far more than it saves.
    if revision(&api.provider(&args.provider).await?) != stamp {
        api.select(OUTBOUND, "REJECT").await?;
        cache.entries.clear();
        cache.delays.clear();
        cache.revision.clear();
        node::save(&cache_path, cache)?;
        return Err("provider changed mid-scan; verdicts discarded".into());
    }

    choose(api, &args.provider, &nodes, cache, !stale.is_empty()).await?;
    node::save(&cache_path, cache)
}

/// One thread is enough: a pass is a handful of HTTP calls per minute.
#[tokio::main(flavor = "current_thread")]
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
    if args.lanes == 0 {
        return Err("--lanes must be at least 1".into());
    }
    tracing_subscriber::fmt()
        .with_ansi(false)
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("mihomo_router=info")),
        )
        .init();
    info!(
        "starting: api={} provider={} state={} interval={}s lanes={} ports={}..{}",
        args.api,
        args.provider,
        args.state.display(),
        args.interval,
        args.lanes,
        args.probe_port,
        args.probe_port + args.lanes as u16 - 1
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

#[cfg(test)]
mod tests {
    use super::tier;

    #[test]
    fn lte_names_are_the_fallback_tier() {
        assert_eq!(tier("🇳🇱 0.1X - LTE №3 - Torrent ✅"), 1);
        assert_eq!(tier("LTE Авто - Нидерланды"), 1);
        assert_eq!(tier("🇫🇮 🎮 ⚡️ ⭐️ Финляндия"), 0);
    }
}
