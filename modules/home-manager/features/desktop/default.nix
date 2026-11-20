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
    ./vicinae.nix
    ./noctalia.nix
    ./zed-editor
    ./telegram.nix
  ];

  # GUI password prompt for polkit actions (run0, pkexec) on Wayland.
  services.polkit-gnome.enable = true;

  xdg = {
    mimeApps = {
      enable = true;

      defaultApplications = {
        "inode/directory" = ["yazi.desktop"];
      };

      associations.added = {
        "inode/directory" = ["yazi.desktop"];
      };
    };
    mime.enable = true;

    terminal-exec = {
      enable = true;

      settings = {
        default = [
          "alacritty.desktop"
        ];
      };
    };

    portal = {
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
  };

  home.packages = with pkgs; [
    wf-recorder
    wl-clipboard
    typst
  ];
}
