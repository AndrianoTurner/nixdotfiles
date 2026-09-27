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
    "rutracker.org"
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
          "--filter-l3=ipv4"
          "--filter-tcp=443"
          "--filter-l7=tls"
          "--payload=tls_client_hello"
          "--lua-desync=fake:blob=fake_default_tls:ip_autottl=-1,3-20:repeats=1"
        ];
      };

      # The empty ACK is sent before SNI is visible, so this phase-zero part
      # cannot be restricted with a hostlist. Keeping it after the targeted
      # TLS profile ensures ClientHello packets still use that profile first.
      tls-empty-ack = {
        priority = 250;
        parameters = [
          "--filter-l3=ipv4"
          "--filter-tcp=443"
          "--payload=empty"
          "--out-range=s1<d1"
          "--lua-desync=pktmod:ip_ttl=1"
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
