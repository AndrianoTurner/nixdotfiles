{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;

    extraPackages = with pkgs; [
      wl-clipboard
      git
      ripgrep
      fd

      # LSP servers / formatters
      rust-analyzer
      rustfmt
      lua-language-server
      nil
      nixfmt
      taplo
    ];
  };

  xdg.configFile."nvim/init.lua".source = ./nvim/init.lua;
}
