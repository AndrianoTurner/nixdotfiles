{...}: {
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # needed for niri
  };
}
