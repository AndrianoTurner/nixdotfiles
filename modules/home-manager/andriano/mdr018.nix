{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    outputs.homeManagerModules.andriano
    outputs.homeManagerModules.cli
    outputs.homeManagerModules.desktop
  ];
  home.packages = with pkgs; [docker-compose];
}
