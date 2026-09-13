{...}: {
  programs.zed-editor.userSettings.languages = {
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
}
