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

      spaces = {
        Personal = {
          id = "bfbbd2bc-4df3-4399-96f6-a0bbcc811b6e";
          position = 1000;
          icon = "🏠";

          pins = {
            YouTube = {
              id = "3a820ea2-8aec-4bad-8319-767cc6ab3d9f";
              url = "https://youtube.com";
              position = 100;
              isEssential = true;
            };
            YouTubeMusic = {
              id = "a9ba4309-19a9-4a2d-8595-fa77ed1bf5f3";
              url = "https://music.youtube.com";
              title = "YouTube Music";
              position = 101;
              isEssential = true;
            };
            VK = {
              id = "6a02490c-0e55-4c13-b0ce-76b67abaf0df";
              url = "https://vk.com";
              position = 102;
            };
            GitHub = {
              id = "ea087720-5d2a-46fd-a58d-20e188e34473";
              url = "https://github.com";
              position = 103;
              isEssential = true;
            };
            NixOSSearch = {
              id = "c1901afa-0a4b-4da2-8729-f04ee83eb818";
              url = "https://search.nixos.org";
              title = "NixOS Search";
              position = 104;
              isEssential = true;
            };
          };
        };
        Work = {
          id = "84628d15-6bdd-4518-93aa-a2ff86f6dec4";
          position = 2000;
          icon = "💼";

          pins = {
            Bitrix24 = {
              id = "d8929275-2e24-4c91-8986-1ef2abe28861";
              url = "https://madrigal.bitrix24.ru";
              position = 200;
            };
            GitLab = {
              id = "740a5417-a6a3-437d-b817-a4d7fb84eaf3";
              url = "https://gitlab.internal.madrigal.ru";
              position = 201;
            };
            SnapIT = {
              id = "a33ff23e-0201-496c-bb5e-1974a31a3ad3";
              url = "https://snapit.internal.madrigal.ru";
              position = 202;
            };
            OpenBao = {
              id = "e44af805-5be8-413d-b3db-6c55e45fd06e";
              url = "https://openbao.internal.madrigal.ru";
              position = 203;
            };
            Timeweb = {
              id = "eca6b7c0-18d0-46a7-8382-77f0db70d7dc";
              url = "https://timeweb.cloud";
              position = 204;
            };
            Selectel = {
              id = "919a40b7-18de-4c7f-949d-f13e5830c447";
              url = "https://selectel.ru";
              position = 205;
            };
          };
        };
      };
    };
  };
}
