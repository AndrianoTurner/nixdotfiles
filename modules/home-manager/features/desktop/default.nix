{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.config
    inputs.zen-browser.homeModules.default
    inputs.noctalia.homeModules.default
    ./font.nix
    ./pavucontrol.nix
    ./playerctl.nix
    ./alacritty.nix
    ./niri
    ./zen-browser.nix
    ./firefox.nix
    ./vicinae.nix
    ./noctalia.nix
    ./zed.nix
    ./telegram.nix
    ./tmux.nix
    ./opencode
  ];

  xdg.mimeApps.enable = true;
  xdg.mime.enable = true;
  home.packages = with pkgs; [
    wf-recorder
    wl-clipboard
    typst
  ];

  xdg.portal = {
    xdgOpenUsePortal = true;
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome]; # or whatever you use
    config = {
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
      };
      common = {
        default = ["gtk"];
      };
    };
  };
}
