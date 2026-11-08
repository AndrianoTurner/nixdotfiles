{
  config,
  lib,
  pkgs,
  ...
}: let
  json = pkgs.formats.json {};

  # Context7 remote MCP (streamable HTTP). The API key is read from the
  # sops-nix secret file at connect time so it never lands in the store.
  mcpConfig = json.generate "pi-mcp.json" {
    mcpServers.context7 = {
      url = "https://mcp.context7.com/mcp";
      headers.CONTEXT7_API_KEY = "!cat ${config.sops.secrets."context7-api-key".path}";
      exposure = "direct";
      description = "Context7: current, version-specific library documentation lookup";
    };
  };

  plannotatorConfig = json.generate "plannotator.json" {
    executionMode = "external";
  };

  subagentConfig = json.generate "pi-subagent-config.json" {
    maxActiveAsyncRunsPerSession = 4;
    timeoutMs = 3600000;
    toolDescriptionMode = "compact";
  };
in {
  programs.pi.coding-agent.settings = {
    modelThinkingLevels."claude-n-codex/claude-sonnet-5" = "xhigh";
    compaction.modelOverrides."claude-n-codex/claude-sonnet-5".reserveTokens = 100000;
  };

  home.file =
    (lib.mapAttrs' (name: text: lib.nameValuePair ".pi/agent/agents/${name}.md" {inherit text;}) (import ./_agents.nix))
    // {
      ".pi/agent/models.json".source = ./models.json;

      # Read-only store symlink: `pi mcp add` writes will fail, edit here.
      ".pi/agent/mcp.json".source = mcpConfig;

      ".pi/agent/APPEND_SYSTEM.md".source =
        ./APPEND_SYSTEM.md;

      ".pi/agent/AGENTS.md".source = ./AGENTS.md;

      ".pi/agent/extensions/plannotator-handoff.ts".source =
        ./extensions/plannotator-handoff.ts;

      ".pi/agent/plannotator.json".source =
        plannotatorConfig;

      ".pi/agent/extensions/subagent/config.json".source =
        subagentConfig;
    };
}
