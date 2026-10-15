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
    ./pi
    ./ssh.nix
  ];

  home.sessionVariables.JAVA_HOME = "${pkgs.jdk21}/lib/openjdk";

  home.packages = with pkgs; [waypipe qbittorrent];
}
