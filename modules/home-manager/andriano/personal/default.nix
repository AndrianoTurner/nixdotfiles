{
  imports = [
    ../global/sops.nix
    ./git.nix
    ./jj.nix
    ./opencode.nix
    ./ssh.nix
  ];

  home.shellAliases.rebuild = "nixos-rebuild switch --flake ~/nixos#$(hostname) --sudo";
}
