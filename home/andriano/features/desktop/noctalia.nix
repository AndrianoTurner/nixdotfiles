{inputs, ...}: {
  imports = [inputs.noctalia.homeModules.default];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        position = "top";
        density = "default";
        widgets = {
          left = [
            {id = "Launcher";}
            {id = "Clock";}
            {id = "ActiveWindow";}
          ];
          center = [
            {id = "Workspace";}
          ];
          right = [
            {id = "Tray";}
            {id = "Volume";}
            {id = "Battery";}
            {id = "ControlCenter";}
          ];
        };
      };
      general = {
        avatarImage = "/home/andriano/.face";
        telemetryEnabled = false;
      };
      colorSchemes.predefinedScheme = "Noctalia (default)";
    };
  };
}
