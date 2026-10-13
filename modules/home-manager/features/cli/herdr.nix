{pkgs, ...}: {
  home.packages = [pkgs.unstablePkgs.herdr pkgs.bun];
}
