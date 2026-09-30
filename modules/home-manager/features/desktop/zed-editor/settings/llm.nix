{
  pkgs,
  lib,
  ...
}: let
  codex-acp = pkgs.unstablePkgs.codex-acp;
in {
  programs.zed-editor.userSettings = {
    agent_servers = {
      codex = {
        type = "custom";
        command = lib.getExe codex-acp;
        args = [];

        env = {
          INITIAL_AGENT_MODE = "agent";
        };
      };
    };
    language_models = {
      ollama = {
        api_url = "http://172.16.20.9:11434";
        context_window = 131072;
        auto_discover = true;
      };
    };
  };
}
