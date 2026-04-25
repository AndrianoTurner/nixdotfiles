{ config, pkgs, ... }:
{
  programs.niri.settings = {
    prefer-no-csd = true;

    hotkey-overlay = {
      skip-at-startup = true;
      hide-not-bound = true;
    };

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    spawn-at-startup = [
      { command = [ "qs" "-c" "noctalia-shell" ]; }
      { command = [ "sh" "-c" "copyq --start-server" ]; }
      { command = [ "vicinae" "server" ]; }
      { command = [ "sh" "-c" "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'" ]; }
      { command = [ "sh" "-c" "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'" ]; }
    ];

    input = {
      keyboard = {
        xkb = {
          layout = "us,ru";
          options = "grp:alt_shift_toggle";
        };
        repeat-delay = 150;
        repeat-rate = 40;
        numlock = true;
      };
      touchpad = { };
      warp-mouse-to-focus = true;
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
    };

    outputs = {
      "LG Electronics MP59G 0x01010101" = {
        mode = { width = 1920; height = 1080; };
        scale = 1.0;
        background-color = "#282828";
      };
      "Xiaomi Corporation Mi Monitor 5790010008157" = {
        mode = { width = 1920; height = 1080; refresh = 180.0; };
        scale = 1.0;
        background-color = "#282828";
        position = { x = -1920; y = 0; };
      };
      "Dell Inc. DELL S2421HS F5P2BP3" = {
        mode = { width = 1920; height = 1080; refresh = 74.973; };
        scale = 1.0;
      };
    };

    layout = {
      gaps = 8;
      center-focused-column = "never";
      always-center-single-column = true;
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
      default-column-width = { proportion = 0.45; };
      focus-ring = {
        enable = true;
        width = 4;
        active.color = "#eab676";
        inactive.color = "#282828";
        urgent.color = "#9b0000";
      };
      border.enable = false;
    };

    binds = with config.lib.niri.actions; {
      # ── Apps ──────────────────────────────────────────────────────────────
      "Mod+Return".action = spawn "alacritty";
      "Mod+R" = { repeat = false; action = spawn "vicinae" "toggle"; };
      "Mod+E".action = spawn "dolphin";
      "Mod+X".action = spawn "sh" "-c" "qs -c noctalia-shell ipc call notifications toggleHistory";
      "Ctrl+Alt+L".action = spawn "sh" "-c" "qs -c noctalia-shell ipc call lockScreen lock";

      # ── Window management ─────────────────────────────────────────────────
      "Mod+Q".action = close-window;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+V".action = toggle-window-floating;
      "Mod+C".action = center-column;
      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      # ── Focus ─────────────────────────────────────────────────────────────
      "Mod+H".action = focus-column-left;
      "Mod+L".action = focus-column-right;
      "Mod+K".action = focus-window-up;
      "Mod+J".action = focus-window-down;
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action = focus-window-up;
      "Mod+Down".action = focus-window-down;

      # ── Move ──────────────────────────────────────────────────────────────
      "Mod+Shift+H".action = move-column-left;
      "Mod+Shift+L".action = move-column-right;
      "Mod+Shift+K".action = move-window-up;
      "Mod+Shift+J".action = move-window-down;
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action = move-window-up;
      "Mod+Shift+Down".action = move-window-down;

      # ── Workspaces ────────────────────────────────────────────────────────
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      # workaround for https://github.com/sodiboo/niri-flake/issues/944
      "Mod+Shift+1".action.move-column-to-workspace = [ 1 ];
      "Mod+Shift+2".action.move-column-to-workspace = [ 2 ];
      "Mod+Shift+3".action.move-column-to-workspace = [ 3 ];
      "Mod+Shift+4".action.move-column-to-workspace = [ 4 ];
      "Mod+Shift+5".action.move-column-to-workspace = [ 5 ];
      "Mod+Shift+6".action.move-column-to-workspace = [ 6 ];
      "Mod+WheelScrollDown" = { cooldown-ms = 150; action = focus-workspace-down; };
      "Mod+WheelScrollUp"   = { cooldown-ms = 150; action = focus-workspace-up; };
      "Mod+Shift+WheelScrollDown".action = focus-column-left;
      "Mod+Shift+WheelScrollUp".action = focus-column-right;
      "Mod+Page_Down".action = focus-workspace-down;
      "Mod+Page_Up".action = focus-workspace-up;

      # ── Monitors ──────────────────────────────────────────────────────────
      "Mod+Ctrl+H".action = focus-monitor-left;
      "Mod+Ctrl+L".action = focus-monitor-right;
      "Mod+Ctrl+K".action = focus-monitor-up;
      "Mod+Ctrl+J".action = focus-monitor-down;
      "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
      "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

      # ── Screenshots ───────────────────────────────────────────────────────
      "Mod+Shift+S".action.screenshot = {}; 

      # ── Session ───────────────────────────────────────────────────────────
      "Mod+Shift+E".action = quit;
      "Ctrl+Alt+Delete".action = quit;
      "Mod+Shift+P".action = power-off-monitors;
      "Mod+O" = { repeat = false; action = toggle-overview; };
      "Mod+Escape" = { allow-inhibiting = false; action = toggle-keyboard-shortcuts-inhibit; };
      "Mod+Shift+Slash".action = show-hotkey-overlay;

      # ── Volume ────────────────────────────────────────────────────────────
      "XF86AudioRaiseVolume" = { allow-when-locked = true; action = spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"; };
      "XF86AudioLowerVolume" = { allow-when-locked = true; action = spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; };
      "XF86AudioMute"        = { allow-when-locked = true; action = spawn "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; };
      "XF86AudioMicMute"     = { allow-when-locked = true; action = spawn "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; };

      # ── Media ─────────────────────────────────────────────────────────────
      "XF86AudioPlay"  = { allow-when-locked = true; action = spawn "playerctl" "play-pause"; };
      "XF86AudioPause" = { allow-when-locked = true; action = spawn "playerctl" "play-pause"; };
      "XF86AudioStop"  = { allow-when-locked = true; action = spawn "playerctl" "stop"; };
      "XF86AudioNext"  = { allow-when-locked = true; action = spawn "playerctl" "next"; };
      "XF86AudioPrev"  = { allow-when-locked = true; action = spawn "playerctl" "previous"; };

      # ── Brightness ────────────────────────────────────────────────────────
      "XF86MonBrightnessUp"   = { allow-when-locked = true; action = spawn "brightnessctl" "s" "10%+"; };
      "XF86MonBrightnessDown" = { allow-when-locked = true; action = spawn "brightnessctl" "s" "10%-"; };
    };
  };
}

