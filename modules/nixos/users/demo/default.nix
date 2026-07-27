{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = true;
  users.users.demo = {
    isNormalUser = true;
    initialPassword = "demo";
    shell = pkgs.fish;
    extraGroups = ifTheyExist [
      "audio"
      "input"
      "video"
      "wheel"
      "networkmanager"
      "render"
    ];

    packages = [pkgs.home-manager];
  };
}
