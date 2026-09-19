{...}: {
  programs.zed-editor.userSettings.languages = {
    Python = {
      language_servers = [
        "ruff"
        "basedpyright"
      ];
    };

    Nix = {
      formatter = "language_server";
      format_on_save = "on";
      language_servers = ["nil"];
    };
  };
}
