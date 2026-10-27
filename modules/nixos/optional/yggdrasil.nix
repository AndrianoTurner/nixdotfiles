{lib, ...}: let
  # Fill these after first boot: run `sudo yggdrasilctl getSelf` on each
  # device and list its Yggdrasil IPv6 address here. Until populated, SSH
  # over ygg0 stays blocked (secure default).
  sshAllowed = [
    "200:3bad:f599:a197:b334:1f16:6d32:cab2"
    # "200:aaaa:bbbb::1234"
    # "200:cccc:dddd::5678"
  ];
in {
  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings = {
      IfName = "ygg0";
      NodeInfoPrivacy = true;
      Peers = [
        "tls://ygg-msk-1.averyan.ru:8362"
        "tls://yggno.de:18227"
        "tls://ru2.cert.dev:7041"
      ];
    };
  };

  networking.firewall.extraInputRules = lib.optionalString (sshAllowed != []) ''
    iifname "ygg0" ip6 saddr { ${lib.concatStringsSep ", " sshAllowed} } tcp dport 22 accept
  '';
}
