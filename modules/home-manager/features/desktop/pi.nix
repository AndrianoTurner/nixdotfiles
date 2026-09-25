{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.pi;
  agentDir = "${config.home.homeDirectory}/.pi/agent";

  models = pkgs.writeText "pi-models.json" (builtins.toJSON {
    providers.ollama = {
      baseUrl = "http://172.16.20.9:11434/v1";
      api = "openai-completions";

      # Pi needs a non-empty provider marker before custom models become
      # selectable. Ollama ignores it, and authHeader=false prevents sending it.
      apiKey = "ollama";
      authHeader = false;

      compat = {
        supportsDeveloperRole = false;
        supportsReasoningEffort = false;
      };

      models = [
        {
          id = "qwen3.8:27b-q8_0";
          name = "Qwen 3.8 27B Q8";
          reasoning = true;
          input = ["text" "image"];
          contextWindow = 131072;
          maxTokens = 32768;
        }
      ];
    };
  });
in {
  imports = [inputs.pi.homeModules.default];

  options.my.pi = {
    qwenModelId = lib.mkOption {
      type = lib.types.str;
      default = "qwen3.8:27b-q8_0";
    };

    qwenModel = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "ollama/${cfg.qwenModelId}";
    };
  };

  config = {
    programs.pi.coding-agent = {
      enable = true;

      settings = {
        defaultProvider = "ollama";
        defaultModel = "qwen3.8:27b-q8_0";
        defaultThinkingLevel = "off";

        defaultProjectTrust = "ask";
        enableInstallTelemetry = false;
        enableAnalytics = false;
        quietStartup = false;

        enabledModels = [
          "ollama/qwen3.8:27b-q8_0"
          "openai-codex/gpt-5.6-luna"
          "openai-codex/gpt-5.6-sol"
        ];

        packages = [
          "npm:pi-web-access"
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

      environment = {
        PI_CODING_AGENT_DIR.value = agentDir;
        PI_SKIP_VERSION_CHECK.value = "1";
        PI_TELEMETRY.value = "0";
      };
    };

    # Keep the model registry declarative. programs.pi.coding-agent.models only
    # installs models.json once, so later Nix changes would otherwise be ignored.
    home.file.".pi/agent/models.json" = {
      source = models;
      force = true;
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
    ];
  };
}
