{...}: {
  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";

      core = {
        editor = "nvim";
        whitespace = "error";
        autocrlf = "input";
        compression = 9;
      };

      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = false;
      };

      blame = {
        coloring = "highlightRecent";
        date = "relative";
      };

      diff = {
        context = 3;
        renames = "copies";
        interHunkContext = 10;
      };

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

      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };

      pull.rebase = true;

      submodule.fetchJobs = 16;

      rebase.autoStash = true;

      rerere.enabled = true;

      gpg.format = "ssh";
    };
  };
}
