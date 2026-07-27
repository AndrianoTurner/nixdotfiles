{
  config,
  lib,
  ...
}: {
  programs.opencode.settings = {
    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama";
        options.baseURL = config.sops.placeholder.internal-ollama-url;
        models = {
          "qwen3-coder-next:q8_0".name = "qwen3-coder-next:q8_0";
          "qwen3.5:122b".name = "qwen3.5:122b";
        };
      };
      openai = {
        npm = "@ai-sdk/openai";
        name = "OpenAI";
        options.apiKey = config.sops.placeholder.openai-api-key;
      };
      glm = {
        npm = "@ai-sdk/openai-compatible";
        name = "GLM";
        options = {
          baseURL = "https://api.z.ai/api/coding/paas/v4/";
          apiKey = config.sops.placeholder.glm-api-key;
        };
        models = {
          "glm-5.1".name = "glm-5.1";
          "glm-5".name = "glm-5";
          "glm-5-turbo".name = "glm-5-turbo";
          "glm-4.7".name = "glm-4.7";
          "glm-4.6".name = "glm-4.6";
          "glm-4.5".name = "glm-4.5";
        };
      };
    };
    mcp.context7 = {
      type = "remote";
      url = "https://mcp.context7.com/mcp";
      headers.CONTEXT7_API_KEY = config.sops.placeholder.context7-api-key;
      enabled = true;
    };
  };

  # Let sops-nix render the merged public and personal settings.
  xdg.configFile."opencode/opencode.json".enable = lib.mkForce false;
  sops.templates."opencode.json" = {
    path = "${config.xdg.configHome}/opencode/opencode.json";
    content = builtins.toJSON config.programs.opencode.settings;
  };

  sops.secrets = {
    internal-ollama-url = {};
    context7-api-key = {};
    openai-api-key = {};
    glm-api-key = {};
  };
}
