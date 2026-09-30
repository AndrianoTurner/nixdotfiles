{pkgs, repoRoot, ...}: {
  imports = ["${repoRoot}/modules/home-manager/users/andriano"];

  home.packages = with pkgs; [docker-compose vault-bin pkgs.unstablePkgs.xpipe];
}
