{
  programs.lazygit.enable = true;
  programs.delta = {
    enable = true;
    enableGitIntegration = true;

    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = false;
      dark = true;
    };
  };
  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";

      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = false;
      };
      interactive.singleKey = true;

      blame = {
        coloring = "highlightRecent";
        date = "relative";
      };

      diff = {
        algorithm = "histogram";
        renames = true;
        colorMoved = "default";
        # Keep unrelated edits as separate hunks.
        interHunkContext = 0;
      };

      merge.conflictStyle = "zdiff3";

      log = {
        abbrevCommit = true;
        graphColors = "blue,yellow,cyan,magenta,green,red";
      };

      status = {
        branch = true;
        short = true;
        showStash = true;
        showUntrackedFiles = "all";
      };

      fetch.prune = true;

      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };

      pull.rebase = true;
      rebase = {
        autoStash = true;
        autoSquash = true;
        updateRefs = true;
        missingCommitsCheck = "warn";
      };

      submodule.fetchJobs = 16;

      rerere.enabled = true;

      commit.verbose = true;

      column.ui = "auto";

      branch.sort = "-committerdate";
      tag.sort = "version:refname";
    };
  };
}
