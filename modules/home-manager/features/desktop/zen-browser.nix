{
  config,
  lib,
  pkgs,
  ...
}: let
  normalExtension = slug: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "normal_installed";
  };
in {
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = lib.mkDefault true;
    nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];

    # These are defaults, not locked preferences. Changes made in Zen take
    # precedence and survive future Home Manager activations.
    extraPrefs = ''
      defaultPref("zen.workspaces.continue-where-left-off", true);
      defaultPref("zen.urlbar.behavior", "float");
      defaultPref("zen.welcome-screen.seen", true);
      defaultPref("browser.startup.homepage", "about:blank");
      defaultPref("browser.newtabpage.enabled", false);
      defaultPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      defaultPref("media.ffmpeg.vaapi.enabled", true);
      defaultPref("gfx.webrender.all", true);
      defaultPref("widget.wayland.fractional-scale.enabled", true);
    '';

    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
      ExtensionSettings = {
        "foxyproxy@eric.h.jung" = normalExtension "foxyproxy-standard";
        "plasma-browser-integration@kde.org" = normalExtension "plasma-integration";
        "jid1-MnnxcxisBPnSXQ@jetpack" = normalExtension "privacy-badger17";
        "clipper@obsidian.md" = normalExtension "web-clipper-obsidian";
        "@testpilot-containers" = normalExtension "multi-account-containers";
        "addon@darkreader.org" = normalExtension "darkreader";
        "uBlock0@raymondhill.net" = normalExtension "ublock-origin";
      };
    };

    profiles.${config.home.username} = {
      isDefault = true;

      mods = [
        "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
        "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
      ];
    };
  };
}
