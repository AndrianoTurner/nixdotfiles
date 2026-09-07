{config, ...}: {
  programs.noctalia = {
    enable = true;

    # config.toml is the declarative baseline. Noctalia keeps changes made in
    # its settings UI in $XDG_STATE_HOME/noctalia/settings.toml, so rebuilds do
    # not discard runtime customization.
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

        greeter_sync.auto_sync = true;

        shadow = {
          direction = "down_right";
          alpha = 0.55;
        };

        panel = {
          transparency_mode = "soft";
          borders = true;
          shadow = true;
          launcher_placement = "floating";
          launcher_position = "center";
          clipboard_placement = "floating";
          clipboard_position = "center";
          control_center_placement = "attached";
          wallpaper_placement = "attached";
          session_placement = "floating";
          session_position = "center";
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

        default.path = "${config.xdg.configHome}/wallpapers/Anime-Girl-Rain.png";
        last.path = "${config.xdg.configHome}/wallpapers/Anime-Girl-Rain.png";

        monitors = {
          "DP-1".path = "${config.xdg.configHome}/wallpapers/Anime-Girl-Rain.png";
          "HDMI-A-1".path = "${config.xdg.configHome}/wallpapers/Fog-Forest-Everforest.png";
          "HDMI-A-3".path = "${config.xdg.configHome}/wallpapers/Anime-Girl-Rain.png";
        };

        favorite = [
          {
            path = "${config.xdg.configHome}/wallpapers/Night_City.png";
            theme_mode = "auto";
          }
        ];

        automation = {
          enabled = true;
          interval_seconds = 120;
          order = "random";
          recursive = true;
        };
      };

      theme = {
        mode = "dark";
        source = "wallpaper";
        builtin = "Noctalia";
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

      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;
        widget_order = [
          "lockscreen-login-box@HDMI-A-3"
          "lockscreen-login-box@DP-1"
          "lockscreen-login-box@HDMI-A-1"
          "lockscreen-widget-0000000000000001"
          "lockscreen-widget-0000000000000003"
          "lockscreen-widget-0000000000000005"
          "lockscreen-widget-0000000000000006"
        ];

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        widget = {
          "lockscreen-login-box@DP-1" = {
            box_height = 196.0;
            box_width = 720.0;
            cx = 960.0;
            cy = 961.0;
            output = "DP-1";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "login_box";

            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = false;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "regular";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_session_buttons = true;
              show_unlock_hint = true;
              show_weather = true;
            };
          };

          "lockscreen-login-box@HDMI-A-1" = {
            box_height = 196.0;
            box_width = 720.0;
            cx = 960.0;
            cy = 956.0;
            output = "HDMI-A-1";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "login_box";

            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = false;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "regular";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_session_buttons = true;
              show_unlock_hint = true;
              show_weather = true;
            };
          };

          "lockscreen-login-box@HDMI-A-3" = {
            box_height = 196.0;
            box_width = 810.0;
            cx = 960.0;
            cy = 898.0;
            output = "HDMI-A-3";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "login_box";

            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = false;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "regular";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_session_buttons = true;
              show_unlock_hint = true;
              show_weather = true;
            };
          };

          lockscreen-widget-0000000000000001 = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 960.0;
            cy = 279.0;
            output = "HDMI-A-1";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "clock";
          };

          lockscreen-widget-0000000000000003 = {
            box_height = 224.0;
            box_width = 240.0;
            cx = 960.0;
            cy = 780.0;
            output = "HDMI-A-1";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "fancy_audio_visualizer";

            settings = {
              background = false;
              visualization_mode = "all";
            };
          };

          lockscreen-widget-0000000000000005 = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 960.0;
            cy = 592.5;
            output = "HDMI-A-1";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "sysmon";

            settings = {
              background_opacity = 0.0;
              background_padding = 16;
              background_radius = 14;
              display = "graph";
              stat = "cpu_usage";
              stat2 = "cpu_temp";
            };
          };

          lockscreen-widget-0000000000000006 = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 960.0;
            cy = 428.0;
            output = "HDMI-A-1";
            placement_height = 1080.0;
            placement_width = 1920.0;
            rotation = 0.0;
            type = "weather";

            settings = {
              background_opacity = 0.87;
              forecast_days = 3;
              show_forecast = true;
            };
          };
        };
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
        disk_used_pct_activity_threshold = 80;
        disk_used_pct_critical_threshold = 90;
      };

      weather = {
        enabled = true;
        effects = true;
        unit = "celsius";
      };

      location = {
        auto_locate = true;
        address = "Rostov-on-Don";
      };

      audio = {
        enable_overdrive = false;
        enable_sounds = false;
      };

      battery.warning_threshold = 20;

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
