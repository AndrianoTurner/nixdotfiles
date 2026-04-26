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

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome]; # or whatever you use
    config = {
      niri = {
        default = ["gnome" "gtk"];
      };
      common = {
        default = ["gtk"];
      };
    };
  };
}
