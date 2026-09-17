{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ../../shared
    ../../features/cli
    ../../features/desktop
    ./sops.nix
    ./git.nix
    ./jj.nix
    ./opencode.nix
    ./pi.nix
    ./ssh.nix
  ];

  home.packages = with pkgs; [waypipe qbittorrent];
}
