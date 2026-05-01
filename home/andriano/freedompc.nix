{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./global
    ./features/cli
    ./features/desktop
  ];
  # TODO: move somewhere
  home.packages = with pkgs; [libreoffice-fresh];
}
