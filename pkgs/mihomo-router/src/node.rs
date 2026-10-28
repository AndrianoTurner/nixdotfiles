//! Time-bounded cache of exit-verification verdicts, keyed by node name.
use std::collections::BTreeMap;
use std::fs;
use std::io::Write;
use std::os::unix::fs::OpenOptionsExt;
use std::path::Path;

use serde::{Deserialize, Serialize};

pub const SUCCESS_TTL_SECS: u64 = 6 * 3600;
pub const FAILURE_TTL_SECS: u64 = 600;

#[derive(Serialize, Deserialize, Clone, Default)]
pub struct Cache {
    /// Provider revision the entries were measured against.
    #[serde(default)]
    pub revision: String,
    #[serde(default)]
    pub entries: BTreeMap<String, Entry>,
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
}

impl Entry {
    /// "non_ru" and the fallback tier's "ru_lte" are selectable; "ru" and
    /// "unverified" never are.
    pub fn eligible(&self, now: f64) -> bool {
        matches!(self.verdict.as_str(), "non_ru" | "ru_lte") && now < self.expires_at
    }
}

pub fn load(path: &Path) -> Cache {
    fs::read(path)
        .ok()
        .and_then(|data| serde_json::from_slice(&data).ok())
        .unwrap_or_default()
}

pub fn save(path: &Path, cache: &Cache) -> Result<(), String> {
    let data = serde_json::to_vec_pretty(cache).map_err(|e| e.to_string())?;
    let tmp = path.with_extension("json.new");
    let mut f = fs::OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .mode(0o600)
        .open(&tmp)
        .map_err(|e| e.to_string())?;
    f.write_all(&data).map_err(|e| e.to_string())?;
    f.sync_all().map_err(|e| e.to_string())?;
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
        }
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
