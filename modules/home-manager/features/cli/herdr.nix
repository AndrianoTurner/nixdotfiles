{pkgs, ...}: let
  herdr = pkgs.unstablePkgs.herdr;
in {
  home.packages = [herdr pkgs.bun];

  # tmux-like setup. Upstream's `programs.herdr` module only exists in
  # home-manager master, which cannot be mixed into release-26.05, so the
  # config file is written here directly.
  xdg.configFile."herdr/config.toml" = {
    source = (pkgs.formats.toml {}).generate "herdr-config.toml" {
      onboarding = false;

      theme.name = "gruvbox";

      ui.prompt_new_tab_name = false;

      keys = {
        prefix = "ctrl+a";

        new_workspace = "prefix+shift+s";
        close_workspace = "prefix+shift+k";

        new_tab = "prefix+n";
        next_tab = "prefix+ctrl+n";
        previous_tab = "prefix+ctrl+p";

        split_horizontal = "prefix+minus";
        split_vertical = "prefix+|";
        close_pane = "prefix+q";
        detach = "prefix+d";

        reload_config = "prefix+r";
        resize_mode = "prefix+shift+r";

        focus_pane_left = ["prefix+h" "alt+h"];
        focus_pane_down = ["prefix+j" "alt+j"];
        focus_pane_up = ["prefix+k" "alt+k"];
        focus_pane_right = ["prefix+l" "alt+l"];
      };
    };

    onChange = "${herdr}/bin/herdr server reload-config || true";
  };
}
