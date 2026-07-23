{pkgs, ...}: {
  imports = [
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
    ./ayugram.nix
    ./tmux.nix
    ./opencode
  ];

  xdg.mimeApps.enable = true;
  xdg.mime.enable = true;
  home.packages = with pkgs; [
    wf-recorder
    wl-clipboard
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
    nerd-fonts._3270
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    nerd-fonts.bigblue-terminal
    nerd-fonts.hack
    nerd-fonts.departure-mono
    typst
  ];

  fonts.fontconfig.enable = true;

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
