{pkgs,...}: {
  imports = [
    ./bindings.nix
    ./settings/appearance.nix
    ./settings/languages.nix
    ./settings/lsp.nix
  ];
  home.packages = [pkgs.nil];

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
  };
}
