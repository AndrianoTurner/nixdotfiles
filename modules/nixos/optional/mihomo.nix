{
  config,
  lib,
  repoRoot,
  ...
}: let
  cfg = config.services.mihomo-router;
  lanes = lib.range 0 (cfg.lanes - 1);
  probeGroup = n:
    "  - name: PROBE-${toString n}\n"
    + "    type: select\n"
    + "    proxies: [REJECT]\n"
    + "    use: [${cfg.provider}]\n";
  probeListener = n:
    "  - name: probe-${toString n}\n"
    + "    type: mixed\n"
    + "    listen: 127.0.0.1\n"
    + "    port: ${toString (cfg.probePort + n)}\n"
    + "    proxy: PROBE-${toString n}\n"
    + "    udp: false\n";
in {
  imports = [./mihomo-router.nix];

  sops.secrets."mihomo-subscription" = {
    sopsFile = "${repoRoot}/secrets/system/mihomo.yaml";
  };

  services.mihomo = {
    enable = true;
    # SOCKS5 + HTTP on one localhost port, no TUN. mihomo owns the
    # subscription and the connections; mihomo-router owns eligibility.
    configFile = config.sops.templates."mihomo.yaml".path;
  };

  services.mihomo-router.enable = true;

  systemd.services.mihomo = {
    after = ["sops-nix.service"];
    serviceConfig = {
      Restart = "always";
      RestartSec = "3s";
    };
  };

  # Static config: one select group the controller drives over the REST API,
  # plus one probe group and listener per lane. Both sides read `lanes` and
  # `probePort` from services.mihomo-router, so they cannot drift apart.
  sops.templates."mihomo.yaml" = {
    content =
      ''
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
          ${cfg.provider}:
            type: http
            url: "${config.sops.placeholder."mihomo-subscription"}"
            interval: 3600

        proxy-groups:
          - name: FOREIGN-OUT
            type: select
            proxies: [REJECT]
            use: [${cfg.provider}]
      ''
      + lib.concatMapStrings probeGroup lanes
      + ''

        listeners:
      ''
      + lib.concatMapStrings probeListener lanes
      + ''

        rules:
          - MATCH,FOREIGN-OUT
      '';
  };
}
