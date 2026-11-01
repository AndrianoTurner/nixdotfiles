{
  lib,
  pkgs,
  ...
}: let
  json = pkgs.formats.json {};

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
