{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./global
    ./features/cli
    ./features/desktop
  ];
  # TODO: move somewhere
  home.packages = with pkgs; [libreoffice-fresh];
}
