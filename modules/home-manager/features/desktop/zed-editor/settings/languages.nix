{...}: {
  programs.zed-editor.userSettings.languages = {
    Python = {
      language_servers = [
        "ruff"
        "basedpyright"
      ];
    };

    "C#" = {
      language_servers = ["csharp-ls"];
      format_on_save = "on";
    };

    Nix = {
      formatter = "language_server";
      format_on_save = "on";
      language_servers = ["nil"];
    };
  };
}
