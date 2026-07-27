{config, ...}: {
  programs.noctalia = {
    enable = true;

    # config.toml is the declarative baseline. Noctalia keeps changes made in
    # its settings UI in a separate settings.toml override, so rebuilds do not
    # discard runtime customization.
    settings = {
      accessibility.ui_scale = 1.0;

      shell = {
        font_family = "JetBrains Mono";
        time_format = "{:%H:%M}";
        date_format = "%a, %b %d";
        telemetry_enabled = false;
        setup_wizard_enabled = false;
        avatar_path = "${config.xdg.configHome}/face";
        clipboard_enabled = true;
        clipboard_auto_paste = "off";

        animation = {
          enabled = true;
          speed = 1.0;
        };

        shadow = {
          direction = "down_right";
          alpha = 0.55;
        };

        panel = {
          transparency_mode = "soft";
          borders = true;
          shadow = true;
          launcher_placement = "centered";
          clipboard_placement = "centered";
          control_center_placement = "attached";
          wallpaper_placement = "attached";
          session_placement = "centered";
          open_near_click_control_center = true;
        };

        launcher = {
          categories = true;
          show_icons = true;
          compact = false;
          app_grid = true;
          sort_by_usage = true;
          auto_paste = "off";
        };

        mpris.blacklist = [];
      };

      wallpaper = {
        enabled = true;
        directory = "${config.xdg.configHome}/wallpapers";
        fill_mode = "crop";
        fill_color = "#000000";
        transition = [
          "fade"
          "disc"
          "stripes"
          "wipe"
          "honeycomb"
        ];
        transition_duration = 1500;
        edge_smoothness = 0.05;
        transition_on_startup = true;

        automation = {
          enabled = true;
          interval_minutes = 2;
          order = "random";
          recursive = true;
        };
      };

      theme = {
        mode = "dark";
        source = "wallpaper";
        wallpaper_scheme = "m3-tonal-spot";
      };

      notification = {
        enable_daemon = true;
        show_app_name = true;
        show_actions = true;
        position = "top_right";
        layer = "overlay";
        background_opacity = 1.0;
      };

      osd = {
        enabled = true;
        position = "top_right";
        background_opacity = 1.0;
      };

      lockscreen = {
        enabled = true;
        blurred_desktop = false;
        wallpaper = "";
        blur_intensity = 0.2;
        tint_intensity = 0.0;
      };

      system.monitor = {
        enabled = true;
        cpu_usage_activity_threshold = 80;
        cpu_usage_critical_threshold = 90;
        cpu_temp_activity_threshold = 80;
        cpu_temp_critical_threshold = 90;
        gpu_temp_activity_threshold = 80;
        gpu_temp_critical_threshold = 90;
        ram_pct_activity_threshold = 80;
        ram_pct_critical_threshold = 90;
        disk_pct_activity_threshold = 80;
        disk_pct_critical_threshold = 90;
      };

      weather = {
        enabled = true;
        effects = true;
        unit = "celsius";
      };

      location = {
        auto_locate = false;
        address = "Rostov-on-Don";
      };

      audio = {
        enable_overdrive = false;
        enable_sounds = false;
      };

      brightness.enable_ddcutil = false;

      nightlight = {
        enabled = false;
        force = false;
        temperature_day = 6500;
        temperature_night = 4000;
      };

      idle = {
        pre_action_fade_seconds = 5.0;
        behavior = {
          "screen-off" = {
            enabled = true;
            timeout = 150;
            action = "screen_off";
          };
          lock = {
            enabled = true;
            timeout = 300;
            action = "lock";
          };
          "lock-and-suspend" = {
            enabled = false;
            timeout = 1800;
            action = "lock_and_suspend";
          };
        };
      };

      bar.main = {
        position = "top";
        thickness = 34;
        background_opacity = 0.93;
        radius = 12;
        margin_h = 4;
        margin_v = 4;
        padding = 8;
        widget_spacing = 6;
        shadow = true;
        reserve_space = true;
        capsule = true;
        capsule_opacity = 0.62;
        margin_ends = 0;

        start = [
          "clock"
          "cpu"
          "temp"
          "ram"
        ];
        center = ["workspaces"];
        end = [
          "media"
          "tray"
          "notifications"
          "battery"
          "volume"
          "brightness"
          "control-center"
        ];
      };

      dock.enabled = false;
      desktop_widgets.enabled = false;

      control_center.shortcuts = [
        {type = "wifi";}
        {type = "bluetooth";}
        {type = "wallpaper";}
        {type = "notification";}
        {type = "power_profile";}
        {type = "caffeine";}
      ];

      hooks.battery_low_percent_threshold = 20;

      widget = {
        clock = {
          format = "{:%H:%M} {:%a, %b %d}";
          tooltip_format = "{:%A, %B %d, %Y}";
        };
        notifications.hide_when_no_unread = false;
      };
    };
  };
}
