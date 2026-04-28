{...}: {
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    attachExistingSession = true;
    settings = {
      theme = "gruvbox-dark";
    };
  };
}
