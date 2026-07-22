{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;

    plugins = with pkgs.vimPlugins; [
      gruvbox-nvim
      mini-nvim
      mini-pick
      blink-cmp
      gitsigns-nvim
      conform-nvim
      typst-preview-nvim
    ];

    extraPackages = with pkgs;
      [
        wl-clipboard
        git
        ripgrep
        fd
        typst
        evince
        websocat

        # LSP servers / formatters
        rust-analyzer
        rustfmt
        lua-language-server
        nil
        nixfmt
        taplo
      ]
      ++ [pkgs.unstablePkgs.tinymist];
  };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
