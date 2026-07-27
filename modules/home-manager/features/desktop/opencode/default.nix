{...}: {
  programs.opencode = {
    enable = true;
    tui = {
      theme = "gruvbox";
    };
    settings = {
      "$schema" = "https://opencode.ai/config.json";
    };
  };

  home.file.".opencode/agents" = {
    source = ./agents;
    recursive = true;
  };
}
