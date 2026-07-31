{
  config,
  inputs,
  pkgs,
  ...
}: let
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
        {id = "qwen3.6:35b";}
        {id = "qwen3.6:27b";}
        {
          id = "qwen3.7-35b-fast:latest";
          name = "Qwen 3.7 35B Fast";
          reasoning = false;
          contextWindow = 131072;
          maxTokens = 32768;
        }
        {id = "aratan/qwen3.7-abliterated-35b-q4:latest";}
        {
          id = "qwen3.5:122b";
          name = "Qwen 3.5 122B";
          reasoning = true;
          contextWindow = 131072;
          maxTokens = 32768;
        }
        {id = "OxW/Qwen3-8b-ru-i1:latest";}
        {id = "qwen3:8b";}
      ];
    };
  });
in {
  imports = [inputs.pi.homeModules.default];

  programs.pi.coding-agent = {
    enable = true;
    models = models;

    settings = {
      defaultProvider = "ollama";
      defaultModel = "qwen3.7-35b-fast:latest";
      defaultThinkingLevel = "off";

      defaultProjectTrust = "ask";
      enableInstallTelemetry = false;
      enableAnalytics = false;
      quietStartup = false;

      enabledModels = [
        "ollama/qwen3.6:35b"
        "ollama/qwen3.6:27b"
        "ollama/qwen3.7-35b-fast:latest"
        "ollama/aratan/qwen3.7-abliterated-35b-q4:latest"
        "ollama/qwen3.5:122b"
        "ollama/OxW/Qwen3-8b-ru-i1:latest"
        "ollama/qwen3:8b"
      ];

      packages = [
        "npm:pi-web-access"
        "npm:context-mode"
        "npm:@tintinweb/pi-subagents"
        "npm:@tintinweb/pi-tasks"
        "npm:@narumitw/pi-plan-mode"
        "npm:@narumitw/pi-lsp"
        "npm:@gotgenes/pi-permission-system"
        "npm:@dietrichgebert/ponytail"
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
}
