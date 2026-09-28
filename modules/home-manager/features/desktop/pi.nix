{
  config,
  inputs,
  pkgs,
  ...
}: let
  agentDir = "${config.home.homeDirectory}/.pi/agent";
in {
  imports = [inputs.pi.homeModules.default];

  config = {
    programs.pi.coding-agent = {
      enable = true;

      settings = {
        defaultProjectTrust = "ask";
        enableInstallTelemetry = false;
        enableAnalytics = false;
        quietStartup = false;

        packages = [
          "npm:pi-web-access"
          "npm:pi-agent-browser-native@0.8.2"
          "npm:@juicesharp/rpiv-todo"
          "npm:@juicesharp/rpiv-ask-user-question"
          "npm:context-mode"
          "npm:pi-subagents"
          "npm:@narumitw/pi-plan-mode"
          "npm:pi-lens"
          "npm:@gotgenes/pi-permission-system"
          "npm:@dietrichgebert/ponytail"
          "npm:pi-cliproxyapi-provider"
        ];

        compaction = {
          enabled = true;
          reserveTokens = 16384;
          keepRecentTokens = 20000;
        };

        retry = {
          enabled = true;
          maxRetries = 3;
          baseDelayMs = 2000;
          provider = {
            timeoutMs = 3600000;
            maxRetries = 0;
            maxRetryDelayMs = 60000;
          };
        };
      };

      # Vendored from github.com/JuliusBrussee/caveman @ 2fd153c
      # (skills/caveman/SKILL.md, MIT). Terse-prose mode, pairs with ponytail.
      skills = [
        ./pi-skills/caveman
      ];

      environment = {
        PI_CODING_AGENT_DIR.value = agentDir;
        PI_SKIP_VERSION_CHECK.value = "1";
        PI_TELEMETRY.value = "0";
        AGENT_BROWSER_EXECUTABLE_PATH.value = "${pkgs.chromium}/bin/chromium";
      };
    };

    home.file.".pi/agent/web-search.json".text = builtins.toJSON {
      searchProvider = "searxng";
      searxngBaseUrl = "http://127.0.0.1:8888";
      ssrf = {
        trustEnvProxy = true;
        allowRanges = [
          "127.0.0.0/8"
          "::1/128"
        ];
      };
    };

    home.packages = with pkgs; [
      # unstablePkgs.agent-browser
      git
      gh
      ripgrep
      fd
      jq
      curl
      wget
      patch
      diffutils
      gnumake
      nodejs_24
      python3
      ffmpeg
      yt-dlp
      chromium
    ];
  };
}
