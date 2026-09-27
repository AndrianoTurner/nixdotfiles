{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    ./sops.nix
    ../../optional/l2tp.nix
  ];

  users.mutableUsers = true;
  users.users.andriano = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ifTheyExist [
      "audio"
      "docker"
      "git"
      "i2c"
      "input"
      "libvirtd"
      "wpa_supplicant"
      "plugdev"
      "podman"
      "video"
      "wheel"
      "wireshark"
      "networkmanager"
      "render"
    ];

    openssh.authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9ll2Ym9q6DWj+1g2M4StjNznQZnozPDsOfyJCb8Hmj andriano@freedompc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFODhQX7odZ3nvZSlE7/pxhWcoVfUVWCBr/sL9UXbBGH andriano@homepc"
    ];

    packages = [pkgs.home-manager];
  };
}
