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

    shellAliases = {
      # eza
      ls = "eza --classify=auto --color --group-directories-first --sort=extension -A";
      la = "eza --classify=auto --color --group-directories-first --sort=extension -a -l --octal-permissions --no-permissions";

      # git
      ga = "git add";
      gam = "git add -A && git commit -m";
      gap = "git add -p";
      gs = "git status";
      gcm = "git commit -m";
      gca = "git commit --amend --no-edit";
      gco = "git checkout";
      gcob = "git checkout -b";
      gb = "git branch";
      gba = "git branch -a";
      gbd = "git branch -d";
      gbD = "git branch -D";
      gp = "git push";
      gpo = "git push origin HEAD";
      gl = "git pull";
      glo = "git pull origin";
      glg = ''git log --graph --pretty=format:"%C(yellow)%h%C(reset) %C(cyan)%ad%C(reset) %C(green)%an%C(reset)%C(auto)%d %C(reset)%s" --date=short'';
      gls = "git log --oneline -10";
      glof = "git log --oneline --first-parent";
      gd = "git diff";
      gds = "git diff --staged";
      gdh = "git diff HEAD";
      gsh = "git show";
      rebuild = "nixos-rebuild switch --flake ~/nixos#$(hostname) --sudo";
    };

    functions = {
      fish_greeting = {
        description = "Custom greeting with random quote";
        body = ''
          set -l normal (set_color normal)
          set -l yellow (set_color F90)
          set -l gray (set_color 888888)

          set powered_msgs \
            "candy!" \
            "rubber bands" \
            "a black hole" \
            logic \
            "electromagnetic cheese" \
            "spaghetti code" \
            "undefined behavior" \
            "coffee and denial" \
            "sheer willpower" \
            "a forgotten \`sudo\`"

          set idx (random 1 (count $powered_msgs))
          printf "$yellow⚡ This terminal session is powered by %s$normal\n" $powered_msgs[$idx]
          echo ""

          set quotes \
            '"The only way to learn a new programming language is by writing programs in it." —Dennis Ritchie' \
            '"Premature optimization is the root of all evil." —Donald Knuth' \
            '"Talk is cheap. Show me the code." —Linus Torvalds' \
            '"Any fool can write code that a computer can understand. Good programmers write code that humans can understand." —Martin Fowler' \
            '"The function of good software is to make the complex appear simple." —Grady Booch' \
            '"First, solve the problem. Then, write the code." —John Johnson' \
            '"Code is like humor. When you have to explain it, its bad." —Cory House' \
            '"Simplicity is the soul of efficiency." —Austin Freeman' \
            '"A good programmer is someone who looks both ways before crossing a one-way street." —Doug Linder' \
            '"Computers are useless. They can only give you answers." —Pablo Picasso' \
            '"The best error message is the one that never shows up." —Anonymous' \
            '"Weeks of coding can save you hours of planning." —Anonymous' \
            '"If it hurts, do it more often." —Jez Humble (on CI/CD 😅)' \
            '"There are only two kinds of languages: the ones people complain about and the ones nobody uses." —Bjarne Stroustrup' \
            '"Its not a bug — its an undocumented feature." —Old Programmer Proverb'

          set q_idx (random 1 (count $quotes))
          echo "Thought for the day:$normal"
          string split ' ' $quotes[$q_idx] | string join ' ' | fold -w 70 -s | sed 's/^/  /' | string replace -r '^  (.*)$' "  $gray\1$normal"
          echo ""
        '';
      };
    };

    interactiveShellInit = ''
      set -gx fish_greeting  # suppress default, our function handles it

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

  # Ensure eza is available (if not already in global packages)
  home.packages = with pkgs; [eza];
}
