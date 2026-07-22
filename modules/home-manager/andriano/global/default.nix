{
  lib,
  pkgs,
  config,
  ...
}: let
  cursorTheme = "Bibata-Modern-Classic";
  cursorSize = 24;
in {
  imports = [
    ./sops.nix
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      warn-dirty = false;
    };
  };

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  xdg.configFile = {
    "face".source = ./face;
    "wallpapers".source = ./wallpapers;
  };

  home = {
    username = lib.mkDefault "andriano";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
    sessionPath = ["$HOME/.local/bin"];
    packages = with pkgs; [
      bibata-cursors
      libreoffice-fresh
    ];
    sessionVariables = {
      XCURSOR_THEME = cursorTheme;
      XCURSOR_SIZE = toString cursorSize;
    };
    pointerCursor = {
      package = pkgs.bibata-cursors;
      name = cursorTheme;
      size = cursorSize;
      gtk.enable = true;
      x11.enable = true;
    };

    shellAliases = {
      rebuild = "nixos-rebuild switch --flake ~/nixos#$(hostname) --sudo";
    };
  };
}
