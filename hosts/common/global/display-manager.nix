{pkgs, ...}: {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = [pkgs.kdePackages.qtmultimedia];
  };

  environment.systemPackages = with pkgs; [
    sddm-astronaut
  ];
}
