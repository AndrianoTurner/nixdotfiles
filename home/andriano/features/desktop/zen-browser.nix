{ inputs, pkgs, ... }:
{
  imports = [ inputs.zen-browser.homeModules.default ];

  programs.zen-browser = {
    enable = true;

    profiles.andriano = {
      isDefault = true;

      settings = {
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "gfx.webrender.all" = true;
      };


      search = {
        default = "ddg";
        force = true;
      };
    };
  };
}
