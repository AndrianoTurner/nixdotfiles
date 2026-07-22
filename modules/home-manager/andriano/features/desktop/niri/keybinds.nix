let
  bindWith = key: options: actionName: actionArgs: {
    ${key} =
      options
      // {
        action.${actionName} = actionArgs;
      };
  };

  bind = key: actionName: actionArgs: bindWith key {} actionName actionArgs;
  spawn = key: command: bind key "spawn" command;
  spawnWith = key: options: command: bindWith key options "spawn" command;
  spawnShellWith = key: options: command: bindWith key options "spawn-sh" command;
in {
  binds =
    # Apps
    (spawn "Mod+Return" ["alacritty"])
    // (spawnWith "Mod+R" {repeat = false;} ["vicinae" "toggle"])
    // (spawn "Mod+E" ["dolphin"])
    // (spawn "Mod+X" ["noctalia" "msg" "panel-toggle" "control-center" "notifications"])
    // (spawn "Ctrl+Alt+L" ["noctalia" "msg" "session" "lock"])
    # Window management
    // (bind "Mod+Q" "close-window" [])
    // (bind "Mod+F" "maximize-column" [])
    // (bind "Mod+Shift+F" "fullscreen-window" [])
    // (bind "Mod+V" "toggle-window-floating" [])
    // (bind "Mod+M" "maximize-window-to-edges" [])
    // (bind "Mod+C" "center-column" [])
    // (bind "Mod+Minus" "set-column-width" "-10%")
    // (bind "Mod+Equal" "set-column-width" "+10%")
    // (bind "Mod+Shift+Minus" "set-window-height" "-10%")
    // (bind "Mod+Shift+Equal" "set-window-height" "+10%")
    # Focus
    // (bind "Mod+H" "focus-column-left" [])
    // (bind "Mod+L" "focus-column-right" [])
    // (bind "Mod+K" "focus-window-up" [])
    // (bind "Mod+J" "focus-window-down" [])
    // (bind "Mod+Left" "focus-column-left" [])
    // (bind "Mod+Right" "focus-column-right" [])
    // (bind "Mod+Up" "focus-window-up" [])
    // (bind "Mod+Down" "focus-window-down" [])
    # Move
    // (bind "Mod+Shift+H" "move-column-left" [])
    // (bind "Mod+Shift+L" "move-column-right" [])
    // (bind "Mod+Shift+K" "move-window-up" [])
    // (bind "Mod+Shift+J" "move-window-down" [])
    // (bind "Mod+Shift+Left" "move-column-left" [])
    // (bind "Mod+Shift+Right" "move-column-right" [])
    // (bind "Mod+Shift+Up" "move-window-up" [])
    // (bind "Mod+Shift+Down" "move-window-down" [])
    # Workspaces
    // (bind "Mod+1" "focus-workspace" 1)
    // (bind "Mod+2" "focus-workspace" 2)
    // (bind "Mod+3" "focus-workspace" 3)
    // (bind "Mod+4" "focus-workspace" 4)
    // (bind "Mod+5" "focus-workspace" 5)
    // (bind "Mod+6" "focus-workspace" 6)
    // (bind "Mod+Shift+1" "move-column-to-workspace" 1)
    // (bind "Mod+Shift+2" "move-column-to-workspace" 2)
    // (bind "Mod+Shift+3" "move-column-to-workspace" 3)
    // (bind "Mod+Shift+4" "move-column-to-workspace" 4)
    // (bind "Mod+Shift+5" "move-column-to-workspace" 5)
    // (bind "Mod+Shift+6" "move-column-to-workspace" 6)
    // (bindWith "Mod+WheelScrollDown" {cooldown-ms = 150;} "focus-workspace-down" [])
    // (bindWith "Mod+WheelScrollUp" {cooldown-ms = 150;} "focus-workspace-up" [])
    // (bind "Mod+Shift+WheelScrollDown" "focus-column-left" [])
    // (bind "Mod+Shift+WheelScrollUp" "focus-column-right" [])
    // (bind "Mod+Page_Down" "focus-workspace-down" [])
    // (bind "Mod+Page_Up" "focus-workspace-up" [])
    # Monitors
    // (bind "Mod+Ctrl+H" "focus-monitor-left" [])
    // (bind "Mod+Ctrl+L" "focus-monitor-right" [])
    // (bind "Mod+Ctrl+K" "focus-monitor-up" [])
    // (bind "Mod+Ctrl+J" "focus-monitor-down" [])
    // (bind "Mod+Shift+Ctrl+H" "move-column-to-monitor-left" [])
    // (bind "Mod+Shift+Ctrl+L" "move-column-to-monitor-right" [])
    # Screenshots
    // (bind "Print" "screenshot" [])
    // (bind "Ctrl+Print" "screenshot-screen" [])
    // (bind "Alt+Print" "screenshot-window" [])
    // (bind "Mod+Shift+S" "screenshot" [])
    # Session
    // (bind "Mod+Shift+E" "quit" [])
    // (bind "Ctrl+Alt+Delete" "quit" [])
    // (bind "Mod+Shift+P" "power-off-monitors" [])
    // (bindWith "Mod+O" {repeat = false;} "toggle-overview" [])
    // (bindWith "Mod+Escape" {allow-inhibiting = false;} "toggle-keyboard-shortcuts-inhibit" [])
    // (bind "Mod+Shift+Slash" "show-hotkey-overlay" [])
    # Volume
    // (spawnShellWith "XF86AudioRaiseVolume" {allow-when-locked = true;} "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0")
    // (spawnShellWith "XF86AudioLowerVolume" {allow-when-locked = true;} "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
    // (spawnShellWith "XF86AudioMute" {allow-when-locked = true;} "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
    // (spawnShellWith "XF86AudioMicMute" {allow-when-locked = true;} "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
    # Media
    // (spawnShellWith "XF86AudioPlay" {allow-when-locked = true;} "playerctl play-pause")
    // (spawnShellWith "XF86AudioPause" {allow-when-locked = true;} "playerctl play-pause")
    // (spawnShellWith "XF86AudioStop" {allow-when-locked = true;} "playerctl stop")
    // (spawnShellWith "XF86AudioNext" {allow-when-locked = true;} "playerctl next")
    // (spawnShellWith "XF86AudioPrev" {allow-when-locked = true;} "playerctl previous")
    # Brightness
    // (spawnWith "XF86MonBrightnessUp" {allow-when-locked = true;} ["brightnessctl" "s" "10%+"])
    // (spawnWith "XF86MonBrightnessDown" {allow-when-locked = true;} ["brightnessctl" "s" "10%-"]);
}
