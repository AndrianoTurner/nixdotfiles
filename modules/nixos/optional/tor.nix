# Tor client SOCKS proxy with censorship-resistant bridges (RU blocklist).
#
# Webtunnel bridges come from the `tor-bridges` flake input (refreshed upstream
# every 6h, so run `nix flake update tor-bridges` before switching). Snowflake
# stays as a fallback: its broker hands out a proxy at connect time, no lines
# needed. Tor tries every configured bridge until one connects.
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  webtunnelBridges = lib.filter (
    line: line != "" && !(lib.hasPrefix "#" line)
  ) (lib.splitString "\n" (builtins.readFile "${inputs.tor-bridges}/TOR-BRIDGES/TOR_BRIDGES_WEBTUNNEL.txt"));
in {
  services.tor = {
    enable = true;
    client = {
      enable = true;
      # 127.0.0.1:9050, local only; apps use socks5h://127.0.0.1:9050.
      socksListenAddress = {
        addr = "127.0.0.1";
        port = 9050;
      };
    };

    settings = {
      UseBridges = true;

      ClientTransportPlugin = [
        # Bridge-line parameters (url/fronts/ice) are rotated by the broker,
        # so pass them explicitly here instead of pinning them in a bridge line.
        "snowflake exec ${pkgs.snowflake}/bin/client -url https://1098762253.rsc.cdn77.org/ -fronts app.datapacket.com,www.datapacket.com -ice stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.telnyx.com:3478,stun:stun.hot-chilli.net:3478,stun:stun.fitauto.ru:3478,stun:stun.m-online.net:3478"
        # unstable: 26.05 ships webtunnel 0.0.4, the bridge list uses ver=0.0.7.
        "webtunnel exec ${pkgs.unstablePkgs.webtunnel}/bin/client"
      ];

      Bridge =
        [
          # Placeholder address/fingerprint: the snowflake broker proxies
          # whatever the client asks for.
          "snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72"
        ]
        ++ webtunnelBridges;
    };
  };
}
