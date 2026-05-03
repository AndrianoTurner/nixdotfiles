{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.zen-browser.homeModules.default];

  programs.zen-browser = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
    };

    setAsDefaultBrowser = true;

    profiles.andriano = {
      isDefault = true;

      mods = [
        "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
        "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
      ];

      settings = {
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "gfx.webrender.all" = true;
      };

      #      containersForce = true; # Delete containers not declared here
      containers = {
        Personal = {
          color = "purple";
          icon = "fingerprint";
          id = 1;
        };
        Work = {
          color = "blue";
          icon = "briefcase";
          id = 2;
        };
        Shopping = {
          color = "yellow";
          icon = "dollar";
          id = 3;
        };
      };
      #spacesForce = true; # Delete spaces not declared here
      spaces = {
        "Personal" = {
          id = "c6de089c-410d-4206-961d-ab11f988d40a";
          position = 1000;
          icon = "🏠";
        };
        "Work" = {
          id = "cdd10fab-4fc5-494b-9041-325e5759195b";
          position = 2000;
          icon = "💼";
          theme = {
            type = "gradient";
            colors = [
              {
                red = 100;
                green = 150;
                blue = 200;
                algorithm = "floating";
                type = "explicit-lightness";
                lightness = 50;
              }
            ];
            opacity = 0.8;
            texture = 0.5;
          };
        };
        "Shopping" = {
          id = "78aabdad-8aae-4fe0-8ff0-2a0c6c4ccc24";
          position = 3000;
          icon = "💸";
        };
      };

      search = {
        default = "ddg";
        force = true;
      };
    };
  };
}
