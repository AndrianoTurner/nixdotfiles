{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./font.nix
    ./pavucontrol.nix
    ./playerctl.nix
    ./alacritty.nix
    ./niri
    ./zen-browser.nix
    ./vicinae.nix
    ./noctalia.nix
    ./clash-verge.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    wf-recorder
    wl-clipboard
    nerd-fonts.jetbrains-mono
  ];

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];

  xdg.portal.enable = true;
}
