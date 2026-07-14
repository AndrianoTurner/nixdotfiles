{...}: {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dynamic_padding = true;
        opacity = 0.8;
      };
      scrolling = {
        history = 15000;
      };
      font = {
        size = 12;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
      };
      cursor = {
        style = {
          shape = "Beam";
          blinking = "Always";
        };
        blink_timeout = 0;
        blink_interval = 500;
      };
      mouse = {
        hide_when_typing = true;
        bindings = [
          {
            mouse = "Right";
            action = "Paste";
          }
        ];
      };
    };
  };
}
