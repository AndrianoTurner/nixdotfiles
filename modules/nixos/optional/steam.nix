{pkgs, ...}: {
  programs.steam.enable = true;
  programs.steam.protontricks.enable = true;
  environment.systemPackages = [pkgs.heroic];
}
