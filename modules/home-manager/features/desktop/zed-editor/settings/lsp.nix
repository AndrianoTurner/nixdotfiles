{pkgs, ...}: {
  programs.zed-editor.userSettings.lsp = {
    "nil" = {
      initialization_options = {
        formatting = {
          command = [
            "${pkgs.alejandra}/bin/alejandra"
            "--quiet"
            "--"
          ];
        };
      };
    };
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
}
