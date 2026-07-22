{
  window-rules = [
    {
      matches = [
        {app-id = "studio";}
        {app-id = "zed";}
      ];
      open-maximized = false;
      default-column-width.fixed = 1300;
    }
    {
      matches = [{title = "^Picture-in-Picture$";}];
      open-floating = true;
      default-column-width.fixed = 480;
      default-window-height.fixed = 270;
      baba-is-float = true;
    }
    {
      matches = [{app-id = "vesktop";}];
      open-focused = false;
    }
    # Noctalia v5 runs its settings UI as a regular application window.
    {
      matches = [{app-id = "dev.noctalia.Noctalia";}];
      open-floating = true;
      default-column-width.fixed = 1080;
      default-window-height.fixed = 920;
    }
    {
      matches = [
        {app-id = "smile";}
        {app-id = "kdenlive";}
      ];
      open-floating = true;
    }
    {
      geometry-corner-radius = {
        top-left = 20.0;
        top-right = 20.0;
        bottom-right = 20.0;
        bottom-left = 20.0;
      };
      clip-to-geometry = true;
    }
  ];
}
