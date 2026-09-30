{...}: {
  programs.zed-editor.userKeymaps = [
    # Zed's Vim keymap already provides <C-w> navigation in editor panes.
    # Extend it to docked panels, including the built-in terminal.
    {
      context = "Dock";
      bindings = {
        "ctrl-w h" = "workspace::ActivatePaneLeft";
        "ctrl-w j" = "workspace::ActivatePaneDown";
        "ctrl-w k" = "workspace::ActivatePaneUp";
        "ctrl-w l" = "workspace::ActivatePaneRight";
      };
    }

    # LazyVim-style leader bindings (Space is the Vim leader key).
    {
      context = "Editor && vim_mode == normal && !menu";
      bindings = {
        "space space" = "file_finder::Toggle";
        "space e" = "project_panel::Toggle";
        "space /" = "buffer_search::Deploy";
        "space s g" = "project_search::SearchInNew";
        "space a a" = "agent::Toggle";
        "space f t" = "terminal_panel::Toggle";
        "space b d" = "pane::CloseActiveItem";
        "space b n" = "pane::ActivateNextItem";
        "space b p" = "pane::ActivatePreviousItem";
        "space c a" = "editor::ToggleCodeActions";
        "space c r" = "editor::Rename";
        "space c f" = "editor::Format";
        "space g g" = "git_panel::Toggle";
        "space g t" = "git_panel::ToggleTreeView";
        "space g b" = "git::Branch";
        "space g c" = "git::Commit";
        "space x x" = "editor::ToggleDiagnostics";
        "[ d" = "editor::GoToPreviousDiagnostic";
        "] d" = "editor::GoToDiagnostic";
        "[ e" = [
          "editor::GoToPreviousDiagnostic"
          {severity = "error";}
        ];
        "] e" = [
          "editor::GoToDiagnostic"
          {severity = "error";}
        ];
        "[ w" = [
          "editor::GoToPreviousDiagnostic"
          {severity = "warning";}
        ];
        "] w" = [
          "editor::GoToDiagnostic"
          {severity = "warning";}
        ];
        "space c s" = "outline_panel::Toggle";
        "space u i" = "editor::ToggleInlayHints";
        "space u b" = "editor::ToggleGitBlameInline";
        "space u w" = "editor::ToggleSoftWrap";
      };
    }
  ];
}
