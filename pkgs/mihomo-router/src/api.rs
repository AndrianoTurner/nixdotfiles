//! Minimal, loopback-only Mihomo REST client.
use std::time::Duration;

use reqwest::{Client, Method, Url};
use serde::Deserialize;
use tracing::debug;

#[derive(Clone)]
pub struct Api {
    client: Client,
    base: Url,
    token: Option<String>,
}

#[derive(Clone, Debug, Deserialize)]
pub struct Proxy {
    pub name: String,
}

#[derive(Deserialize)]
pub struct Provider {
    #[serde(rename = "updatedAt", default)]
    pub updated_at: String,
    #[serde(default)]
    pub proxies: Vec<Proxy>,
}

#[derive(Deserialize)]
pub struct Group {
    #[serde(default)]
    pub now: String,
}

#[derive(Deserialize)]
struct Delay {
    delay: u32,
}

impl Api {
    pub fn new(base: &str, token: Option<String>) -> Result<Self, String> {
        let base = Url::parse(base).map_err(|e| e.to_string())?;
        if base.scheme() != "http"
            || base.host_str() != Some("127.0.0.1")
            || base.port_or_known_default().is_none()
        {
            return Err("API must be http://127.0.0.1:<port>".into());
        }
        let client = Client::builder()
            .no_proxy()
            .connect_timeout(Duration::from_secs(3))
            .timeout(Duration::from_secs(15))
            .build()
            .map_err(|e| e.to_string())?;
        Ok(Self {
            client,
            base,
            token,
        })
    }

    fn url(&self, segments: &[&str]) -> Result<Url, String> {
        let mut url = self.base.clone();
        {
            let mut path = url.path_segments_mut().map_err(|_| "bad API URL")?;
            path.clear();
            for segment in segments {
                path.push(segment);
            }
        }
        Ok(url)
    }

    async fn request(
        &self,
        method: Method,
        path: &[&str],
        body: Option<serde_json::Value>,
    ) -> Result<reqwest::Response, String> {
        let url = self.url(path)?;
        debug!("{method} {}", url.path());
        let mut request = self.client.request(method, url);
        if let Some(token) = &self.token {
            request = request.bearer_auth(token);
        }
        if let Some(body) = body {
            request = request.json(&body);
        }
        request
            .send()
            .await
            .map_err(|e| e.to_string())?
            .error_for_status()
            .map_err(|e| e.to_string())
    }

    pub async fn provider(&self, name: &str) -> Result<Provider, String> {
        self.request(Method::GET, &["providers", "proxies", name], None)
            .await?
            .json()
            .await
            .map_err(|e| e.to_string())
    }

    pub async fn group(&self, name: &str) -> Result<Group, String> {
        self.request(Method::GET, &["proxies", name], None)
            .await?
            .json()
            .await
            .map_err(|e| e.to_string())
    }

    /// Select `node` in `group` without reading the group back.
    pub async fn set(&self, group: &str, node: &str) -> Result<(), String> {
        self.request(
            Method::PUT,
            &["proxies", group],
            Some(serde_json::json!({ "name": node })),
        )
        .await
        .map(|_| ())
    }

    /// Select `node` in `group` and confirm the switch really happened.
    pub async fn select(&self, group: &str, node: &str) -> Result<(), String> {
        self.set(group, node).await?;
        let active = self.group(group).await?;
        if active.now != node {
            return Err(format!(
                "selection of {group} not confirmed (got {})",
                active.now
            ));
        }
        debug!("{group} now {node:?}");
        Ok(())
    }

    /// Latency of one provider node, measured by mihomo itself.
    pub async fn delay(&self, provider: &str, node: &str) -> Result<u32, String> {
        let mut url = self.url(&["providers", "proxies", provider, node, "healthcheck"])?;
        url.query_pairs_mut()
            .append_pair("url", "https://www.gstatic.com/generate_204")
            .append_pair("timeout", "5000");
        let mut request = self.client.get(url);
        if let Some(token) = &self.token {
            request = request.bearer_auth(token);
        }
        let delay: Delay = request
            .send()
            .await
            .map_err(|e| e.to_string())?
            .error_for_status()
            .map_err(|e| e.to_string())?
            .json()
            .await
            .map_err(|e| e.to_string())?;
        if delay.delay == 0 {
            return Err("zero delay (node unreachable)".into());
        }
        debug!("healthcheck {node:?}: {} ms", delay.delay);
        Ok(delay.delay)
    }
}
