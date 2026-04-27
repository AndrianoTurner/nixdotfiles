{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];

  services.strongswan.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-l2tp
    networkmanager-strongswan
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
          route3 = "172.16.20.2/32,,0";
          dns = "172.16.0.101";
          dns-search = "internal.madrigal.ru";
        };
        ipv6.method = "disabled";
      };
    };
  };
}
