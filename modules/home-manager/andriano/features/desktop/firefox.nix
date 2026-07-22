{config, ...}: {
  programs.firefox = {
    enable = true;

    configPath = ".mozilla/firefox";

    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
    };
    profiles.${config.home.username} = {
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "gfx.webrender.all" = true;
        "widget.wayland.fractional-scale.enabled" = true;
      };
      #    containersForce = true;
    };
  };
}
