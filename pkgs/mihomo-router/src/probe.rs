//! Exit verification through one of the controller's fixed probe listeners.
use std::net::IpAddr;
use std::time::Duration;

use reqwest::{Client, Proxy};
use serde_json::Value;

use crate::node::{Entry, FAILURE_TTL_SECS, SUCCESS_TTL_SECS};
use crate::now;

struct Source {
    ip: IpAddr,
    country: String,
}

async fn cloudflare(client: &Client) -> Result<Source, String> {
    let text = client
        .get("https://www.cloudflare.com/cdn-cgi/trace")
        .send()
        .await
        .map_err(|e| format!("cloudflare: {e}"))?
        .error_for_status()
        .map_err(|e| format!("cloudflare: {e}"))?
        .text()
        .await
        .map_err(|e| format!("cloudflare: {e}"))?;
    let field = |key: &str| text.lines().find_map(|line| line.strip_prefix(key));
    let ip = field("ip=").ok_or("cloudflare: no ip")?.trim().to_string();
    let country = field("loc=").ok_or("cloudflare: no loc")?.trim().to_string();
    Ok(Source {
        ip: ip.parse().map_err(|e| format!("cloudflare: bad ip {ip}: {e}"))?,
        country,
    })
}

async fn ipinfo(client: &Client) -> Result<Source, String> {
    let v: Value = client
        .get("https://ipinfo.io/json")
        .send()
        .await
        .map_err(|e| format!("ipinfo: {e}"))?
        .error_for_status()
        .map_err(|e| format!("ipinfo: {e}"))?
        .json()
        .await
        .map_err(|e| format!("ipinfo: {e}"))?;
    let ip = v["ip"].as_str().ok_or("ipinfo: no ip")?.to_string();
    let country = v["country"].as_str().ok_or("ipinfo: no country")?.to_string();
    Ok(Source {
        ip: ip.parse().map_err(|e| format!("ipinfo: bad ip {ip}: {e}"))?,
        country,
    })
}

fn public_ip(ip: IpAddr) -> bool {
    match ip {
        IpAddr::V4(x) => {
            !(x.is_private()
                || x.is_loopback()
                || x.is_link_local()
                || x.is_multicast()
                || x.is_unspecified()
                || x.is_broadcast()
                || x.is_documentation())
        }
        IpAddr::V6(x) => {
            !(x.is_loopback()
                || x.is_unique_local()
                || x.is_unicast_link_local()
                || x.is_multicast()
                || x.is_unspecified())
        }
    }
}

fn valid_country(cc: &str) -> bool {
    cc.len() == 2 && cc.bytes().all(|b| b.is_ascii_alphabetic())
}

/// Probe the node currently selected in the listener's probe group.
/// Both sources must succeed with a public, valid country. A Russian exit is
/// fatal unless `allow_ru` (the metered fallback tier), which keeps the node
/// selectable but only behind every verified non-RU node.
pub async fn verify(port: u16, allow_ru: bool) -> Entry {
    let checked_at = now();
    let mut entry = Entry {
        verdict: "unverified".into(),
        reason: "pending".into(),
        checked_at,
        expires_at: checked_at + FAILURE_TTL_SECS as f64,
        exit_ips: vec![],
        countries: vec![],
    };
    let result = async {
        let client = Client::builder()
            .no_proxy()
            .proxy(Proxy::all(format!("http://127.0.0.1:{port}")).map_err(|e| e.to_string())?)
            .connect_timeout(Duration::from_secs(5))
            .timeout(Duration::from_secs(12))
            .build()
            .map_err(|e| e.to_string())?;
        let (a, b) = tokio::join!(cloudflare(&client), ipinfo(&client));
        let sources = vec![a?, b?];
        for s in &sources {
            if !public_ip(s.ip) {
                return Err(format!("non-public exit address {}", s.ip));
            }
            if !valid_country(&s.country) {
                return Err(format!("bad country code {:?}", s.country));
            }
        }
        let ru = sources.iter().any(|s| s.country.eq_ignore_ascii_case("RU"));
        Ok::<_, String>((sources, ru))
    }
    .await;

    match result {
        Ok((sources, ru)) => {
            entry.exit_ips = sources.iter().map(|s| s.ip.to_string()).collect();
            entry.countries = sources.iter().map(|s| s.country.to_uppercase()).collect();
            if ru {
                if allow_ru {
                    entry.verdict = "ru_lte".into();
                    entry.reason = format!(
                        "exit {} is RU (fallback tier allowed)",
                        entry.exit_ips.join(",")
                    );
                    entry.expires_at = checked_at + SUCCESS_TTL_SECS as f64;
                } else {
                    entry.verdict = "ru".into();
                    entry.reason = format!("exit {} is RU", entry.exit_ips.join(","));
                }
            } else {
                entry.verdict = "non_ru".into();
                entry.reason = format!("exit {} is {}", entry.exit_ips.join(","), entry.countries.join("/"));
                entry.expires_at = checked_at + SUCCESS_TTL_SECS as f64;
            }
        }
        Err(e) => entry.reason = e,
    }
    entry
}
