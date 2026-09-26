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
    ./yazi-file-chooser.nix
    ./niri
    ./zen-browser.nix
    ./vicinae.nix
    ./noctalia.nix
    ./zed-editor
    ./telegram.nix
    ./tmux.nix
    ./opencode
    ./pi.nix
  ];

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
  };

  home.packages = with pkgs; [
    wf-recorder
    wl-clipboard
    typst
  ];
}
