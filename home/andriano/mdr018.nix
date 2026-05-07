{ pkgs, ... }:
{
  imports = [
    ./global
    ./features/cli
    ./features/desktop
  ];
  home.packages = with pkgs; [ docker-compose ];
}
