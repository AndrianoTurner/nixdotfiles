{pkgs-unstable,...}:{
services.mihomo = {
  enable = true;
  tunMode = true;
  configFile = "/etc/mihomo/config.yaml";
  };
environment.etc."mihomo/config.yaml".text = ''
  mixed-port: 7890
  allow-lan: false
  mode: rule
  log-level: info
  tun:
    enable: true
    stack: system
    auto-route: true
    auto-detect-interface: true
'';

security.wrappers.clash-verge = {
  owner = "root";
  group = "root";
  capabilities = "cap_net_admin+ep";
  source = "${pkgs-unstable.clash-verge-rev}/bin/clash-verge";
};
}

