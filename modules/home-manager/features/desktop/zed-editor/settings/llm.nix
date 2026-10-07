{
  pkgs,
  lib,
  ...
}: {
  programs.zed-editor.userSettings = {
    agent_servers = {
      pi = {
        type = "custom";
        command = lib.getExe pkgs.pi-acp;
        args = [];
        env = {};
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
