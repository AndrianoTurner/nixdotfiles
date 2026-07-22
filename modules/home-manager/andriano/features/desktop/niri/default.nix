{pkgs, ...}: {
  programs.niri = {
    package = pkgs.niri;
    settings =
      import ./settings.nix
      // import ./keybinds.nix
      // import ./windowrules.nix;
  };

  home.packages = with pkgs; [
    brightnessctl
    wireplumber
    kdePackages.dolphin
    playerctl
  ];
}
