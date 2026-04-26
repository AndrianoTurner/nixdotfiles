{...}: {
  programs.nixvim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.gruvbox.enable = true; # or tokyonight, catppuccin, etc.

    plugins = {
      # LazyVim core equivalents
      lualine.enable = true;
      bufferline.enable = true;
      neo-tree.enable = true;
      telescope.enable = true;
      treesitter.enable = true;
      noice.enable = true;
      notify.enable = true;
      which-key.enable = true;
      indent-blankline.enable = true;
      gitsigns.enable = true;
      mini-icons = {
        enable = true;
        mockDevIcons = true;
      };
      # LSP
      lsp = {
        enable = true;
        servers = {
          lua_ls.enable = true;
          nil_ls.enable = true; # nix
          # add whatever you need
        };
      };
      cmp.enable = true;
      luasnip.enable = true;

      # extras
      flash.enable = true;
      todo-comments.enable = true;
      trouble.enable = true;
      lazygit.enable = true;
    };

    keymaps = [
      {
        key = "<leader>e";
        action = ":Neotree toggle<CR>";
        options.desc = "Toggle file tree";
      }
      {
        key = "<leader>ff";
        action = ":Telescope find_files<CR>";
        options.desc = "Find files";
      }
      {
        key = "<leader>fg";
        action = ":Telescope live_grep<CR>";
        options.desc = "Live grep";
      }
      {
        key = "<leader>gg";
        action = ":LazyGit<CR>";
        options.desc = "LazyGit";
      }
    ];

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      scrolloff = 8;
    };
  };
}
