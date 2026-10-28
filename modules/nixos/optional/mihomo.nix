{
  config,
  pkgs,
  repoRoot,
  ...
}: {
  sops.secrets."mihomo-subscription" = {
    sopsFile = "${repoRoot}/secrets/system/mihomo.yaml";
  };

  services.mihomo = {
    enable = true;
    # SOCKS5 + HTTP on one localhost port, no TUN. mihomo owns the
    # subscription and the connections; mihomo-router owns eligibility.
    configFile = config.sops.templates."mihomo.yaml".path;
  };

  systemd.services.mihomo = {
    after = ["sops-nix.service"];
    serviceConfig = {
      Restart = "always";
      RestartSec = "3s";
    };
  };

  # Static config: four permanent probe listeners plus one select group the
  # controller drives over the REST API. Listener ports must match PROBE_PORT
  # in pkgs/mihomo-router/src/main.rs (4 lanes, 17800..17803).
  sops.templates."mihomo.yaml" = {
    content = ''
      mixed-port: 7890
      allow-lan: false
      mode: rule
      log-level: info
      ipv6: true
      unified-delay: true
      tcp-concurrent: true

      # Loopback only, no secret: nothing but mihomo-router talks to it.
      external-controller: 127.0.0.1:9090

      proxy-providers:
        vless:
          type: http
          url: "${config.sops.placeholder."mihomo-subscription"}"
          interval: 3600

      proxy-groups:
        - name: FOREIGN-OUT
          type: select
          proxies: [REJECT]
          use: [vless]
        - name: PROBE-0
          type: select
          proxies: [REJECT]
          use: [vless]
        - name: PROBE-1
          type: select
          proxies: [REJECT]
          use: [vless]
        - name: PROBE-2
          type: select
          proxies: [REJECT]
          use: [vless]
        - name: PROBE-3
          type: select
          proxies: [REJECT]
          use: [vless]

      listeners:
        - name: probe-0
          type: mixed
          listen: 127.0.0.1
          port: 17800
          proxy: PROBE-0
          udp: false
        - name: probe-1
          type: mixed
          listen: 127.0.0.1
          port: 17801
          proxy: PROBE-1
          udp: false
        - name: probe-2
          type: mixed
          listen: 127.0.0.1
          port: 17802
          proxy: PROBE-2
          udp: false
        - name: probe-3
          type: mixed
          listen: 127.0.0.1
          port: 17803
          proxy: PROBE-3
          udp: false

      rules:
        - MATCH,FOREIGN-OUT
    '';
  };

  # Long-running controller: discovers provider nodes, verifies their real
  # exit country through the probe listeners, then selects FOREIGN-OUT.
  systemd.services.mihomo-router = {
    description = "Mihomo exit-country controller";
    wantedBy = ["multi-user.target"];
    wants = ["mihomo.service"];
    after = ["mihomo.service"];
    serviceConfig = {
      ExecStart = "${pkgs.mihomo-router}/bin/mihomo-router --api http://127.0.0.1:9090 --state /var/lib/mihomo-router";
      StateDirectory = "mihomo-router";
      DynamicUser = true;
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
