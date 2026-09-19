{pkgs, ...}: {
  imports = [
    ./zoxide.nix
    ./starship.nix
  ];

  programs.nix-your-shell = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "plugin-git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];

    shellAliases = {
      l = "lsd -l";
      la = "lsd -a";
      lla = "lsd -la";
      lt = "lsd --tree";
    };

    functions = {
      fish_greeting = {
        description = "Custom greeting with random quote";

        body = ''
          set -l normal (set_color normal)
          set -l orange (set_color F90)
          set -l gray   (set_color 888888)

          set -l powered_msgs \
            "candy!" \
            "rubber bands" \
            "a black hole" \
            "logic" \
            "electromagnetic cheese" \
            "spaghetti code" \
            "undefined behavior" \
            "coffee and denial" \
            "sheer willpower" \
            "a forgotten `sudo`"

          set -l quotes (
            string match -rv '^\s*(#|$)' < ${./quotes.txt}
          )

          set -l powered_msg (random choice $powered_msgs)
          set -l quote (random choice $quotes)

          printf '%s⚡ This terminal session is powered by %s%s\n\n' \
            $orange $powered_msg $normal

          printf '%sThought for the day:%s\n' $orange $normal

          printf '%s\n' $quote \
            | fold -s -w 70 \
            | while read -l line
                printf '  %s%s%s\n' $gray $line $normal
              end

          echo
        '';
      };
    };

    interactiveShellInit = ''

      set -g fish_color_normal normal
      set -g fish_color_command F75D00
      set -g fish_color_keyword F75D00
      set -g fish_color_quote A8FF3E
      set -g fish_color_redirection 00BFFF
      set -g fish_color_end FF4500
      set -g fish_color_error FF0000
      set -g fish_color_param FFD700
      set -g fish_color_comment 808080
      set -g fish_color_selection --background=F75D00
      set -g fish_color_search_match --background=F75D00
      set -g fish_color_operator FF8C00
      set -g fish_color_escape FF6347
      set -g fish_color_autosuggestion 808080
      set -g fish_pager_color_selected_background --background=F75D00


          # Nix dev shell aliases — only active inside nix develop
               if set -q IN_NIX_SHELL
                 if set -q CARGO_NIGHTLY; and set -q RUSTC_NIGHTLY
                   alias cargo-nightly="RUSTC=$RUSTC_NIGHTLY $CARGO_NIGHTLY"
                 end
               end
    '';
  };

  home.packages = with pkgs; [lsd];
}
