{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    ./sops.nix
  ];

  users.mutableUsers = true;
  users.users.andriano = {
    initialPassword = "changeme";
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

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMq0Cp/YyGh+S690gzjHYQpAjEpyI3MBBA6nfSbC2xpV andriano@freedompc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcp3qsBhzBFR25wqfIKxd4emLEhniZ58cRi5ugNGUSn andriano@homepc"
    ];

    packages = [pkgs.home-manager];
  };
}
