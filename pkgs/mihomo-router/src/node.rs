//! Time-bounded cache of exit-verification verdicts, keyed by node name.
use std::collections::BTreeMap;
use std::fs;
use std::io::Write;
use std::os::unix::fs::OpenOptionsExt;
use std::path::Path;

use serde::{Deserialize, Serialize};

pub const SUCCESS_TTL_SECS: u64 = 6 * 3600;
pub const FAILURE_TTL_SECS: u64 = 600;
/// Cap for the failure backoff, so a node that recovers is retried eventually.
pub const MAX_FAILURE_TTL_SECS: u64 = 6 * 3600;
/// A RU exit does not become eligible on the next pass; re-verifying it often
/// only burns a probe lane.
pub const RU_TTL_SECS: u64 = 12 * 3600;
/// Latency ranking lifetime. Latency drifts, but re-measuring it costs one
/// mihomo healthcheck per eligible node on every pass.
pub const RANK_TTL_SECS: u64 = 1800;

#[derive(Serialize, Deserialize, Clone, Default)]
pub struct Cache {
    /// Provider revision the entries were measured against.
    #[serde(default)]
    pub revision: String,
    #[serde(default)]
    pub entries: BTreeMap<String, Entry>,
    /// Last measured latency per node, reused until `ranked_at` goes stale.
    #[serde(default)]
    pub delays: BTreeMap<String, u32>,
    #[serde(default)]
    pub ranked_at: f64,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Entry {
    /// "non_ru" | "ru_lte" | "ru" | "unverified"
    pub verdict: String,
    pub reason: String,
    pub checked_at: f64,
    pub expires_at: f64,
    #[serde(default)]
    pub exit_ips: Vec<String>,
    #[serde(default)]
    pub countries: Vec<String>,
    /// Consecutive failed verifications, drives the backoff TTL.
    #[serde(default)]
    pub failures: u32,
}

impl Entry {
    /// "non_ru" and the fallback tier's "ru_lte" are selectable; "ru" and
    /// "unverified" never are.
    pub fn eligible(&self, now: f64) -> bool {
        matches!(self.verdict.as_str(), "non_ru" | "ru_lte") && now < self.expires_at
    }

    /// Backoff for a failed verification: 10 min, doubling per consecutive
    /// failure up to the cap. Dead nodes would otherwise be re-probed every
    /// pass forever.
    pub fn failure_ttl(failures: u32) -> u64 {
        FAILURE_TTL_SECS
            .saturating_mul(1 << failures.saturating_sub(1).min(6))
            .min(MAX_FAILURE_TTL_SECS)
    }
}

pub fn load(path: &Path) -> Cache {
    fs::read(path)
        .ok()
        .and_then(|data| serde_json::from_slice(&data).ok())
        .unwrap_or_default()
}

pub fn save(path: &Path, cache: &Cache) -> Result<(), String> {
    let data = serde_json::to_vec(cache).map_err(|e| e.to_string())?;
    let tmp = path.with_extension("json.new");
    let mut f = fs::OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .mode(0o600)
        .open(&tmp)
        .map_err(|e| e.to_string())?;
    f.write_all(&data).map_err(|e| e.to_string())?;
    // Verdicts are reconstructible: plain data sync is enough, and it runs
    // once per probe batch.
    f.sync_data().map_err(|e| e.to_string())?;
    fs::rename(&tmp, path).map_err(|e| e.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn entry(verdict: &str, expires_at: f64) -> Entry {
        Entry {
            verdict: verdict.into(),
            reason: String::new(),
            checked_at: 0.0,
            expires_at,
            exit_ips: vec![],
            countries: vec![],
            failures: 0,
        }
    }

    #[test]
    fn failure_ttl_backs_off_up_to_the_cap() {
        assert_eq!(Entry::failure_ttl(1), FAILURE_TTL_SECS);
        assert_eq!(Entry::failure_ttl(2), 2 * FAILURE_TTL_SECS);
        assert_eq!(Entry::failure_ttl(4), 8 * FAILURE_TTL_SECS);
        assert_eq!(Entry::failure_ttl(9), MAX_FAILURE_TTL_SECS);
    }

    #[test]
    fn only_fresh_allowed_verdicts_are_eligible() {
        assert!(entry("non_ru", 10.0).eligible(5.0));
        assert!(entry("ru_lte", 10.0).eligible(5.0));
        assert!(!entry("non_ru", 5.0).eligible(5.0));
        assert!(!entry("ru_lte", 5.0).eligible(5.0));
        assert!(!entry("ru", 10.0).eligible(5.0));
        assert!(!entry("unverified", 10.0).eligible(5.0));
    }

    #[test]
    fn save_then_load_roundtrip() {
        let dir = std::env::temp_dir().join(format!("mihomo-router-test-{}", std::process::id()));
        fs::create_dir_all(&dir).unwrap();
        let path = dir.join("cache.json");
        let mut cache = Cache {
            revision: "rev".into(),
            ..Cache::default()
        };
        cache.entries.insert("node".into(), entry("non_ru", 10.0));
        save(&path, &cache).unwrap();
        let loaded = load(&path);
        assert_eq!(loaded.revision, "rev");
        assert!(loaded.entries["node"].eligible(1.0));
        let _ = fs::remove_dir_all(&dir);
    }
}
