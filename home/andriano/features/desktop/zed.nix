{...}: {
  programs.zed-editor = {
    enable = true;
    extensions = [
      "ansible"
      "html"
      "toml"
      "dockerfile"
      "terraform"
      "nix"
      "docker-compose"
      "gruvbox"
    ];
    userSettings = {
      autosave = "on_focus_change";
      vim_mode = true;
      format_on_save = "on";

      # Theme: Gruvbox (ensure the extension is installed above)
      theme = "Gruvbox"; # or "Gruvbox Dark", "Gruvbox Light" — check extension docs

      diagnostics = {
        inline = {
          enabled = true;
          max_severity = "error";
        };
      };

      languages = {
        Python = {
          language_servers = ["ruff" "basedpyright"];
        };
      };

      lsp = {
        "rust-analyzer" = {
          initialization_options = {
            check = {
              command = "clippy";
            };
            inlayHints = {
              maxLength = null;
              lifetimeElisionHints = {
                enable = "skip_trivial";
                useParameterNames = true;
              };
              closureReturnTypeHints = {
                enable = "always";
              };
            };
          };
        };
      };
    };
  };
}
