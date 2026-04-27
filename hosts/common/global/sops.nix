{config, ...}: {
  sops = {
    defaultSopsFile = ../secrets.yaml;
    age = {
      sshKeyPaths = ["/etc/ssh/id_ed25519"];
      keyFile = "/var/lib/sops-nix/keys.txt";
      generateKey = true;
    };

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
