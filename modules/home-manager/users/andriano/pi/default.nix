{
  config,
  lib,
  pkgs,
  ...
}: let
  json = pkgs.formats.json {};

  # Read Context7's API key at connect time so it never lands in the store.
  mcpConfig = json.generate "pi-mcp.json" {
    mcpServers.context7 = {
      url = "https://mcp.context7.com/mcp";
      headers.CONTEXT7_API_KEY = "!cat ${config.sops.secrets."context7-api-key".path}";
      exposure = "direct";
      description = "Context7: current, version-specific library documentation lookup";
    };
    mcpServers.rea = {
      command = "${pkgs.nodejs_24}/bin/node";
      args = [
        "${config.home.homeDirectory}/.pi/agent/npm/node_modules/rea-agents/scripts/rea.mjs"
        "mcp"
      ];
      exposure = "deferred";
      description = "REA: local reverse engineering of binaries, JavaScript/Electron apps and .NET assemblies";
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
    extensions = ["+builtin:mcp"];
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
