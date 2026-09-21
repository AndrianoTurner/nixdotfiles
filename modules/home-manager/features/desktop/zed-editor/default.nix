{pkgs, ...}: {
  imports = [
    ./bindings.nix
    ./settings/appearance.nix
    ./settings/languages.nix
    ./settings/lsp.nix
    ./settings/llm.nix
  ];
  home.packages = [pkgs.nil pkgs.tinymist];

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
      "typst"
      "git-firefly"
    ];
  };
}
