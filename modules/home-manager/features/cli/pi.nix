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
          "npm:pi-web-access@0.44.0"
          "npm:pi-agent-browser-native@0.9.6"
          "npm:@juicesharp/rpiv-todo@2.14.0"
          "npm:@juicesharp/rpiv-ask-user-question@2.14.0"
          "npm:billion-context"
          "npm:pi-powerline-footer"
          "npm:@narumitw/pi-usage"
          "npm:pi-mcp-adapter"
          "npm:@narumitw/pi-btw"
          "npm:pi-subagents@0.81.0"
          "npm:@plannotator/pi-extension"
          "npm:pi-lens"
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
          maxRetries = 8;
          baseDelayMs = 2000;
          maxAgentDelayMs = 30000;
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
        JAVA_HOME.value = "${pkgs.jdk21}/lib/openjdk";
        REA_JADX_MCP_JAR.value = "${config.home.homeDirectory}/.local/share/rea/android/jadx-headless-mcp-0.7.1-all.jar";
        # Extensions calling bare globalThis.fetch (pi-usage's chatgpt.com
        # wham/usage) bypass bili's patch; undici ignores http(s)_proxy unless
        # the flag is set, and chatgpt.com direct answers a geo-block 403.
        NODE_USE_ENV_PROXY.value = "1";
        HTTPS_PROXY.value = "http://127.0.0.1:2080";
        HTTP_PROXY.value = "http://127.0.0.1:2080";
        NO_PROXY.value = "localhost,127.0.0.1,::1,172.16.20.91";
      };
    };

    xdg.configFile."billion-context/billion-context.json".text = builtins.toJSON {
      host = "127.0.0.1";
      # Keep package updates under Pi's package manager and retain pi-subagents.
      autoUpdate = false;
      advisoryCheck = false;
      pi.subagents = false;
      # Model egress must ride Throne (localhost:2080): chatgpt.com answers a
      # geo-block 403 HTML page otherwise, which bili reports as
      # "Responses exchange ended without a terminal event". bili strips
      # http(s)_proxy from its own proxy child, so name it here explicitly.
      upstreamProxy = "http://127.0.0.1:2080";
      # The cpa (cliproxyapi) is on the private mesh; Throne cannot reach it and
      # drops the connection (bili "proxy-reset" -> pi 502 acp-proxy failure).
      # Empty proxy = explicitly direct for this host only.
      providers."http://172.16.20.91:8317".proxy = "";
      providers."https://claude-n-codex.com:8443".proxy = "http://127.0.0.1:2080";
      providers."https://api.deepseek.com".proxy = "";
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
      nodejs_24
      jdk21
      python3
      gnumake
      stdenv.cc
      git
      gh
      ripgrep
      fd
      jq
      curl
      wget
      patch
      diffutils
      ffmpeg
      yt-dlp
      chromium
      agent-browser-bin
    ];
  };
}
