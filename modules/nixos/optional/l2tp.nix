{
  pkgs,
  config,
  ...
}: let
  # Strongswan dropped default support in 6.1
  strongswanIKEv1 = pkgs.strongswan.overrideAttrs (old: {
    configureFlags =
      (old.configureFlags or [])
      ++ ["--enable-ikev1"];
  });
in {
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];

  networking.firewall.checkReversePath = "loose";
  networking.firewall.allowedUDPPorts = [500 4500 1701];
  networking.networkmanager.plugins = [
    (pkgs.networkmanager-l2tp.override {
      strongswan = strongswanIKEv1;
    })
    pkgs.networkmanager-strongswan
  ];
  environment.etc."strongswan.conf" = {
    text = '''';
  };
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [config.sops.templates.l2tp-env.path];
    profiles = {
      mdr = {
        connection = {
          id = "mdr";
          type = "vpn";
          autoconnect = false;
        };

        vpn = {
          service-type = "org.freedesktop.NetworkManager.l2tp";
          gateway = "$L2TP_DOMAIN";
          user = "$L2TP_USER";

          ipsec-enabled = "yes";
          ipsec-psk = "$L2TP_PSK";
          ipsec-gateway-id = "%any";
          password-flags = "0";
        };

        vpn-secrets = {
          password = "$L2TP_PASS";
        };

        ipv4 = {
          method = "auto";

          never-default = "true";

          ignore-auto-routes = "true";
          ignore-auto-dns = "false";

          route1 = "172.16.0.100/32,,0";
          route2 = "172.16.0.101/32,,0";
          route3 = "172.16.16.0/20,,0";
          dns = "172.16.0.101";
          dns-search = "internal.madrigal.ru";
        };
        ipv6.method = "disabled";
      };
    };
  };

  sops = {
    secrets = {
      l2tp-psk = {
        group = "networkmanager";
        mode = "0440";
      };
      l2tp-user = {
        group = "networkmanager";
        mode = "0440";
      };
      l2tp-pass = {
        group = "networkmanager";
        mode = "0440";
      };
      l2tp-domain = {
        group = "networkmanager";
        mode = "0440";
      };
    };

    templates.l2tp-env = {
      group = "networkmanager";
      mode = "0440";
      content = ''
        L2TP_PSK=${config.sops.placeholder.l2tp-psk}
        L2TP_USER=${config.sops.placeholder.l2tp-user}
        L2TP_PASS=${config.sops.placeholder.l2tp-pass}
        L2TP_DOMAIN=${config.sops.placeholder.l2tp-domain}
      '';
    };
  };
}
