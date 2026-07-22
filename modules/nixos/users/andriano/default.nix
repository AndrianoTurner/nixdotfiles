{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.myConfig.primaryUser;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  options.myConfig.primaryUser = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Name of the primary interactive user";
    };

    homeModule = lib.mkOption {
      type = lib.types.deferredModule;
      description = "Home Manager module assigned to the primary user";
    };
  };

  config = {
    users.mutableUsers = true;
    users.users.${cfg.name} = {
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

      packages = [pkgs.home-manager];
    };

    home-manager.users.${cfg.name}.imports = [cfg.homeModule];
  };
}
