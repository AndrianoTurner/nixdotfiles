{pkgs-old, ...}: {
  programs.throne = {
    enable = true;
    tunMode.enable = true;
    package = pkgs-old.throne;
  };
}
