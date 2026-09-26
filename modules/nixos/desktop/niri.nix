{pkgs, ...}: {
  programs.niri.enable = true;
  programs.niri.useNautilus = false;

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-termfilechooser
  ];
}
