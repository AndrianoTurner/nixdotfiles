{
  programs.nushell = {
    enable = true;

    shellAliases = {
      l = "lsd -l";
      la = "lsd -a";
      lla = "lsd -la";
      lt = "lsd --tree";

      gb = "git branch";
      gbl = "git branch --all";
      gco = "git checkout";
      gs = "git status";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      gca = "git commit --amend";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log";
      glog = "git log --oneline --decorate --graph";
      gf = "git fetch";
      gpl = "git pull";
      gps = "git push";
      gst = "git stash";
      gsta = "git stash apply";
      gstp = "git stash pop";
      grb = "git rebase";
      grbi = "git rebase --interactive";
    };
  };

  programs.direnv.enableNushellIntegration = true;
  programs.eza.enableNushellIntegration = true;
  programs.nix-your-shell.enableNushellIntegration = true;
  programs.starship.enableNushellIntegration = true;
  programs.zoxide.enableNushellIntegration = true;
  programs.yazi.enableNushellIntegration = true;
}
