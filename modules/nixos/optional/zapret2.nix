{
  inputs,
  pkgs,
  ...
}: let
  targetedHosts = [
    "youtube.com"
    "youtu.be"
    "googlevideo.com"
    "ytimg.com"
    "youtube-nocookie.com"
    "youtube.googleapis.com"
    "youtubei.googleapis.com"
    "yt3.ggpht.com"
    "discord.com"
    "discord.gg"
    "discordapp.com"
    "discordapp.net"
    "discordcdn.com"
    "discord.media"
  ];
in {
  imports = [
    ({
      config,
      lib,
      pkgs,
      utils,
      ...
    }: let
      upstreamModule = import "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/zapret2.nix" {
        inherit config lib pkgs utils;
      };
    in
      upstreamModule
      // {
        # The stable manual does not yet contain redirects for this unstable
        # module's documentation anchors. Keep the module itself intact while
        # excluding only its manual page from the stable documentation build.
        meta = builtins.removeAttrs upstreamModule.meta ["doc"];
      })
  ];

  services.zapret2 = {
    enable = true;
    package = pkgs.unstablePkgs.zapret2;

    firewall = {
      configureAutomatically = true;
      interfaces = null;
      maxPackets = 16;
      tcpPorts = [
        80
        443
      ];
      udpPorts = [443];
      queue = 200;
    };

    profiles = {
      http = {
        priority = 100;
        hosts.include = targetedHosts;
        parameters = [
          "--filter-tcp=80"
          "--filter-l7=http"
          "--payload=http_req"
          "--lua-desync=fake:blob=fake_default_http:tcp_md5"
          "--lua-desync=multisplit:pos=method+2"
        ];
      };

      tls = {
        priority = 200;
        hosts.include = targetedHosts;
        parameters = [
          "--filter-tcp=443"
          "--filter-l7=tls"
          "--payload=tls_client_hello"
          "--lua-desync=fake:blob=fake_default_tls:tcp_md5:tcp_seq=-10000"
          "--lua-desync=multidisorder:pos=1,midsld"
        ];
      };

      quic = {
        priority = 300;
        hosts.include = targetedHosts;
        parameters = [
          "--filter-udp=443"
          "--filter-l7=quic"
          "--payload=quic_initial"
          "--lua-desync=fake:blob=fake_default_quic:repeats=6"
        ];
      };
    };
  };

  environment.systemPackages = [pkgs.unstablePkgs.zapret2];
}
