{
  config,
  repoRoot,
  ...
}: {
  sops.secrets."mihomo-subscription" = {
    sopsFile = "${repoRoot}/secrets/system/mihomo.yaml";
  };

  services.mihomo = {
    enable = true;
    # SOCKS5 + HTTP on one localhost port, no TUN.
    configFile = config.sops.templates."mihomo.yaml".path;
  };

  systemd.services.mihomo = {
    after = ["sops-nix.service"];
    serviceConfig = {
      Restart = "always";
      RestartSec = "3s";
    };
  };

  sops.templates."mihomo.yaml" = {
    content = ''
      mixed-port: 7890
      allow-lan: false
      mode: rule
      log-level: info
      ipv6: true
      unified-delay: true
      tcp-concurrent: true

      proxy-providers:
        vless:
          type: http
          url: "${config.sops.placeholder."mihomo-subscription"}"
          interval: 3600
          health-check:
            enable: true
            url: https://www.gstatic.com/generate_204
            interval: 60
            timeout: 5000
            lazy: false
            expected-status: 204

      proxy-groups:
        - name: AUTO
          type: url-test
          use:
            - vless
          url: https://www.gstatic.com/generate_204
          interval: 60
          tolerance: 50
          lazy: false

      rules:
        - MATCH,AUTO
    '';
  };
}
