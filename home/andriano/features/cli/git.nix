{
  pkgs,
  config,
  lib,
  ...
}: {

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user = {
        name = "AndrianoTurner";
        email = lib.mkDefault "danya.shibaev@gmail.com";
      };
      aliases = {
        p = "pull --ff-only";
        ff = "merge --ff-only";
        graph = "log --decorate --oneline --graph";
        pushall = "!git remote | xargs -L1 git push --all";
      };
      init.defaultBranch = "main";
      gpg.program = "${config.programs.gpg.package}/bin/gpg2";

      merge.conflictStyle = "zdiff3";
      commit.verbose = true;
      diff.algorithm = "histogram";
      log.date = "iso";
      column.ui = "auto";
      branch.sort = "committerdate";
      # Automatically track remote branch
      push.autoSetupRemote = true;
      # Reuse merge conflict fixes when rebasing
      rerere.enabled = true;
    };
    lfs.enable = true;
    ignores = [
      ".direnv"
      "result"
      ".jj"
    ];
};
}

