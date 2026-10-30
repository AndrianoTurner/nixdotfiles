{
  config,
  lib,
  pkgs,
  ...
}: let
  herdr = pkgs.unstablePkgs.herdr;
in {
  home.packages = [herdr pkgs.bun];

  home.activation.herdrAnnotate = lib.hm.dag.entryAfter ["writeBoundary"] ''
    DRY_RUN="''${DRY_RUN:-}" ${pkgs.python3}/bin/python3 ${./herdr-link.py} \
      ${herdr}/bin/herdr ${pkgs.herdr-annotate} \
      ${lib.escapeShellArg config.xdg.configHome} ${lib.escapeShellArg config.xdg.stateHome}
  '';

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

        command = [
          {
            key = "prefix+a";
            type = "plugin_action";
            command = "annotate.capture";
            description = "annotate selected or copied text";
          }
          {
            key = "prefix+shift+a";
            type = "plugin_action";
            command = "annotate.copy-context";
            description = "copy annotations";
          }
          {
            # Repeating Ctrl+A sends a literal prefix, so use Ctrl+Y instead.
            key = "prefix+ctrl+y";
            type = "plugin_action";
            command = "annotate.copy-archive";
            description = "copy annotations and archive them";
          }
          {
            key = "prefix+ctrl+v";
            type = "plugin_action";
            command = "annotate.paste-archive";
            description = "paste annotations without submitting, then archive";
          }
          {
            key = "prefix+m";
            type = "plugin_action";
            command = "annotate.manage";
            description = "manage notes and archives";
          }
          {
            key = "prefix+ctrl+d";
            type = "plugin_action";
            command = "annotate.open";
            description = "review documents in the focused folder";
          }
          {
            key = "prefix+shift+o";
            type = "plugin_action";
            command = "annotate.last";
            description = "choose a recent agent reply to review";
          }
          {
            key = "prefix+ctrl+o";
            type = "plugin_action";
            command = "annotate.last-newest";
            description = "review the newest agent reply";
          }
          {
            key = "prefix+t";
            type = "plugin_action";
            command = "annotate.terminal";
            description = "review recent terminal output";
          }
        ];
      };
    };

    onChange = "${herdr}/bin/herdr server reload-config || true";
  };
}
