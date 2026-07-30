{ inputs, pkgs, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ../../shared
    ../../features/cli
    ../../features/desktop
    ./sops.nix
    ./git.nix
    ./jj.nix
    ./opencode.nix
    ./ssh.nix
  ];

  home.packages = with pkgs; [ waypipe ];

  home.shellAliases.rebuild = "nixos-rebuild switch --flake ~/nixos#$(hostname) --sudo";
}
