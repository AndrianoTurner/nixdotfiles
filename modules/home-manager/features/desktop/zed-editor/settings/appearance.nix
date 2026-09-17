{pkgs, ...}: {
  programs.zed-editor.userSettings = {
    theme = "Gruvbox Dark";

    cli_default_open_behavior = "new_window";

    vim_mode = true;

    autosave = "on_focus_change";
    format_on_save = "on";

    # Fonts
    buffer_font_family = "JetBrainsMono Nerd Font";
    ui_font_family = "JetBrainsMono Nerd Font";
    terminal.font_family = "JetBrainsMono Nerd Font";

    # Terminal
    terminal.shell.program = "${pkgs.fish}/bin/fish";

    project_panel.dock = "left";

    # Predictions
    show_edit_predictions = false;
    features = {
      edit_prediction_provider = "none";
    };

    # slop
    agent = {
      enabled = true;
      button = true;
    };
    disable_ai = false;

    diagnostics = {
      inline = {
        enabled = true;
        max_severity = "error";
      };
    };
  };
}
