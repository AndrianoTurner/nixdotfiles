{...}: {
  programs.zed-editor.userSettings = {
    language_models = {
      ollama = {
        api_url = "http://172.16.20.9:11434";
        context_window = 131072;
        auto_discover = true;
      };
    };
  };
}
