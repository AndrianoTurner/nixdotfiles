{pkgs, ...}: let
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
  home.file = {
    ".pi/agent/APPEND_SYSTEM.md".source =
      ./APPEND_SYSTEM.md;

    ".pi/agent/agents" = {
      source = ./agents;
      recursive = true;
    };

    ".pi/agent/extensions/plannotator-handoff.ts".source =
      ./extensions/plannotator-handoff.ts;

    ".pi/agent/plannotator.json".source =
      plannotatorConfig;

    ".pi/agent/extensions/subagent/config.json".source =
      subagentConfig;
  };
}
