{pkgs, ...}: {
  home.packages = with pkgs; [
    nil
    alejandra
  ];

  programs.zed-editor = {
    enable = true;

    mutableUserDebug = false;
    mutableUserSettings = false;
    mutableUserKeymaps = false;
    mutableUserTasks = false;

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

    userKeymaps = [
      # Window splits (like <C-w> motions)
      {
        bindings = {
          "ctrl-w h" = "workspace::ActivatePaneLeft";
        };
        context = "Workspace";
      }
      {
        bindings = {
          "ctrl-w l" = "workspace::ActivatePaneRight";
        };
        context = "Workspace";
      }
      {
        bindings = {
          "ctrl-w k" = "workspace::ActivatePaneUp";
        };
        context = "Workspace";
      }
      {
        bindings = {
          "ctrl-w j" = "workspace::ActivatePaneDown";
        };
        context = "Workspace";
      }
      {
        bindings = {
          "ctrl-w v" = "pane::SplitRight";
        };
        context = "Workspace";
      }
      {
        bindings = {
          "ctrl-w s" = "pane::SplitDown";
        };
        context = "Workspace";
      }

      # (<space> in normal mode)
      # File finder  → <space>ff
      {
        bindings = {
          "space f f" = "file_finder::Toggle";
        };
        context = "Editor && vim_mode == normal";
      }
      # New file     → <space>fn
      {
        bindings = {
          "space f n" = "workspace::NewFile";
        };
        context = "Editor && vim_mode == normal";
      }

      # Grep / live search → <space>sg
      {
        bindings = {
          "space s g" = "workspace::NewSearch";
        };
        context = "Editor && vim_mode == normal";
      }
      # Command palette   → <space>sp (like Telescope's command search)
      {
        bindings = {
          "space s p" = "command_palette::Toggle";
        };
        context = "Editor && vim_mode == normal";
      }

      # Buffers / tabs
      {
        bindings = {
          "space b d" = "pane::CloseActiveItem";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "space b b" = "tab_switcher::Toggle";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "shift-h" = "pane::ActivatePreviousItem";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "shift-l" = "pane::ActivateNextItem";
        };
        context = "Editor && vim_mode == normal";
      }

      {
        bindings = {
          "space e" = "workspace::ToggleLeftDock";
        };
        context = "Editor && vim_mode == normal";
      }

      {
        bindings = {
          "space c a" = "editor::ToggleCodeActions";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "space c r" = "editor::Rename";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "space c f" = "editor::Format";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "g d" = "editor::GoToDefinition";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "g D" = "editor::GoToDeclaration";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "g r" = "editor::FindAllReferences";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "g I" = "editor::GoToImplementation";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "g t" = "editor::GoToTypeDefinition";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "K" = "editor::Hover";
        };
        context = "Editor && vim_mode == normal";
      }

      {
        bindings = {
          "space x x" = "diagnostics::Deploy";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "] d" = "editor::GoToDiagnostic";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "[ d" = "editor::GoToPreviousDiagnostic";
        };
        context = "Editor && vim_mode == normal";
      }

      {
        bindings = {
          "ctrl-`" = "workspace::ToggleBottomDock";
        };
        context = "Workspace";
      }

      {
        bindings = {
          "] c" = "editor::GoToHunk";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "[ c" = "editor::GoToPreviousHunk";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "space g g" = "git_panel::ToggleFocus";
        };
        context = "Editor && vim_mode == normal";
      }
      {
        bindings = {
          "space g b" = "git::Blame";
        };
        context = "Editor && vim_mode == normal";
      }
    ];

    userSettings = {
      buffer_font_family = "JetBrainsMono Nerd Font";
      ui_font_family = "JetBrainsMono Nerd Font";
      terminal = {
        font_family = "JetBrainsMono Nerd Font";
        shell = {
          program = "${pkgs.fish}/bin/fish";
        };
      };

      show_edit_predictions = false;
      features = {
        edit_prediction_provider = "none";
      };
      agent = {
        enabled = false;
        button = false;
      };
      disable_ai = true;

      autosave = "on_focus_change";
      vim_mode = true;
      format_on_save = "on";

      theme = "Gruvbox Dark";
      diagnostics = {
        inline = {
          enabled = true;
          max_severity = "error";
        };
      };

      languages = {
        Python = {
          language_servers = [
            "ruff"
            "basedpyright"
          ];
        };

        Nix = {
          language_servers = [
            "nil"
            "!nixd"
          ];
        };
      };

      lsp = {
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
    };
  };
}
