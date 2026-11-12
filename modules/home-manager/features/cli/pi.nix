{
  config,
  inputs,
  pkgs,
  ...
}: let
  agentDir = "${config.home.homeDirectory}/.pi/agent";
  proxy = "http://localhost:7890";
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
          "npm:pi-web-access@0.47.0"
          "npm:pi-agent-browser-native@0.9.18"
          "npm:@juicesharp/rpiv-todo@2.15.0"
          "npm:@juicesharp/rpiv-ask-user-question@2.15.0"
          "npm:billion-context@0.1.213"
          "npm:pi-powerline-footer@0.22.0"
          "npm:@narumitw/pi-usage@0.69.2"
          "npm:@narumitw/pi-btw@0.63.5"
          "npm:pi-subagents@0.87.0"
          "npm:@plannotator/pi-extension@0.28.56"
          "npm:@dietrichgebert/ponytail@5.3.3"
          "npm:pi-cliproxyapi-provider@0.16.8"
          "npm:rea-agents@6.9.0"
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
        ./pi-skills/gitlab
        ./pi-skills/nix
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
        NO_PROXY.value = "localhost,127.0.0.1,::1,172.16.20.91";
      };
    };

    xdg.configFile."billion-context/billion-context.json".text = builtins.toJSON {
      host = "127.0.0.1";
      # Keep package updates under Pi's package manager and retain pi-subagents.
      autoUpdate = false;
      advisoryCheck = false;
      pi.subagents = false;
      # Inline posture re-wraps globalThis.fetch alongside pi-web-access
      # (#1158/#1662) and every model request dies as "Connection error."
      # (seen 2026-11-10: cpa and deepseek both, 0 tokens, ~620ms).
      pi.inline = false;
      # Model egress must ride Throne (localhost:2080): chatgpt.com answers a
      # geo-block 403 HTML page otherwise, which bili reports as
      # "Responses exchange ended without a terminal event". bili strips
      # http(s)_proxy from its own proxy child, so name it here explicitly.
      upstreamProxy = "${proxy}";
      # The cpa (cliproxyapi) is on the private mesh; Throne cannot reach it and
      # drops the connection (bili "proxy-reset" -> pi 502 acp-proxy failure).
      # Empty proxy = explicitly direct for this host only.
      providers."http://172.16.20.91:8317".proxy = "";
      providers."https://claude-n-codex.com:8443".proxy = "";
      providers."https://api.deepseek.com".proxy = "";
    };

    home.packages = with pkgs; [
      nodejs_24
      jdk21
      python3
      gnumake
      stdenv.cc
      git
      gh
      glab
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
