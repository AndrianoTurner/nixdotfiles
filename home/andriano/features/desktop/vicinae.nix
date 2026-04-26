{ pkgs-unstable, ... }:
{
  programs.vicinae = {
    enable = true;
    package = pkgs-unstable.vicinae;
    systemd.enable = true;
    systemd.autoStart = true;
  };
}
