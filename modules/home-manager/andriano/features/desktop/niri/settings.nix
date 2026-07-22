{
  spawn-at-startup = [
    {argv = ["noctalia"];}
  ];

  hotkey-overlay = {
    skip-at-startup = true;
    hide-not-bound = true;
  };

  # Allows notification actions and window activation from Noctalia.
  debug.honor-xdg-activation-with-invalid-serial = [];

  prefer-no-csd = true;

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

    touchpad.enable = false;
    warp-mouse-to-focus.enable = true;
    focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "0%";
    };
  };

  gestures.hot-corners.enable = false;

  layout = {
    gaps = 8;
    center-focused-column = "never";
    always-center-single-column = true;
    preset-column-widths = [
      {proportion = 0.33333;}
      {proportion = 0.5;}
      {proportion = 0.66667;}
    ];
    default-column-width.proportion = 0.45;

    focus-ring = {
      enable = true;
      width = 4;
      active.color = "#eab676";
      inactive.color = "#282828";
      urgent.color = "#9b0000";
    };

    border.enable = false;
    struts = {};
  };

  outputs = {
    "LG Electronics MP59G 0x01010101" = {
      mode = {
        width = 1920;
        height = 1080;
      };
      scale = 1;
      background-color = "#282828";
    };

    "Xiaomi Corporation Mi Monitor 5790010008157" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 180.0;
      };
      scale = 1;
      background-color = "#282828";
      position = {
        x = -1920;
        y = 0;
      };
    };

    "Dell Inc. DELL S2421HS F5P2BP3" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 74.973;
      };
      scale = 1;
    };
  };

  cursor = {
    hide-when-typing = true;
    hide-after-inactive-ms = 1500;
  };

  animations = {};
}
