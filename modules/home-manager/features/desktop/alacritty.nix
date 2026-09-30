{
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        dynamic_padding = true;
        opacity = 0.92;
        decorations = "None";
      };

      scrolling.history = 50000;

      font = {
        size = 12;
        normal.family = "JetBrainsMono Nerd Font";
        builtin_box_drawing = true;
      };

      cursor = {
        style = {
          shape = "Beam";
          blinking = "On";
        };

        vi_mode_style = {
          shape = "Block";
          blinking = "Off";
        };

        blink_timeout = 0;
        blink_interval = 500;
        unfocused_hollow = true;
        thickness = 0.15;
      };

      selection.save_to_clipboard = true;
      mouse.hide_when_typing = true;
    };
  };
}
