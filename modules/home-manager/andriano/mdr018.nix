{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    outputs.homeManagerModules.profiles.personal
  ];
  home.packages = with pkgs; [docker-compose];
}
