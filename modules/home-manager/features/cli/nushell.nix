{
  programs.nushell = {
    enable = true;
  };

  programs.direnv.enableNushellIntegration = true;
  programs.eza.enableNushellIntegration = true;
  programs.nix-your-shell.enableNushellIntegration = true;
  programs.starship.enableNushellIntegration = true;
  programs.zoxide.enableNushellIntegration = true;
  programs.yazi.enableNushellIntegration = true;
}
