{pkgs, ...}: {
  programs.vicinae = {
    enable = true;
    package = pkgs.unstablePkgs.vicinae;
    systemd = {
      enable = true;
      autoStart = true;
    };
    settings = {
      close_on_focus_loss = true;
      pop_to_root_on_close = true;

      font.normal = {
        family = "JetBrainsMono Nerd Font";
        size = 12;
      };

      theme = {
        dark = {
          name = "gruvbox-dark";
          icon_theme = "default";
        };
      };

      launcher_window = {
        opacity = 0.95;
      };
    };
  };

  # Standard module doesnt expose it :(
  systemd.user.services.vicinae.Service.Environment = [
    "USE_LAYER_SHELL=1"
  ];
}
