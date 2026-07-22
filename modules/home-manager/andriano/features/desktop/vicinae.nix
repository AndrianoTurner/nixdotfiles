{pkgs, ...}: {
  programs.vicinae = {
    enable = true;
    package = pkgs.unstablePkgs.vicinae;
    systemd.enable = true;
    systemd.autoStart = true;
  };
}
