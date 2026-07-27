{
  pkgs,
  lib,
  ...
}: {
  programs.niri = {
    package = pkgs.niri;
    settings =
      import ./settings.nix {inherit pkgs lib;}
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
