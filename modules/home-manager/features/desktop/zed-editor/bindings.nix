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
  ];
}
