{pkgs, ...}: {
  imports = [../../modules/home-manager/users/andriano];

  home.packages = with pkgs; [docker-compose];
}
