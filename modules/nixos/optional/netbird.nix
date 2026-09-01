{config, ...}: {
  sops.secrets.netbird-setup-key = {
    key = "netbird/setup-key";
    mode = "0400";
  };

  services.resolved.enable = true;

  services.netbird.clients.wt0 = {
    port = 51821;

    ui.enable = false;

    # Allow direct P2P WireGuard connections normally.
    openFirewall = true;
    openInternalFirewall = true;

    login = {
      enable = true;
      setupKeyFile = config.sops.secrets.netbird-setup-key.path;
    };
  };
}
