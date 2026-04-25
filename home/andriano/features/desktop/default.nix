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
    ./niri.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    wf-recorder
    wl-clipboard
  ];


  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];

  xdg.portal.enable = true;
}

