{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/users/andriano
    ../common/optional/pipewire.nix
    ../common/optional/systemd-boot.nix
    ../common/optional/docker.nix
    #    ../common/optional/mihomo.nix
  ];
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.openssh.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # use proprietary kernel module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      nvidiaBusId = "PCI:1@0:0:0";
      amdgpuBusId = "PCI:65@0:0:0"; # If you have an AMD iGPU
    };
  };

  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  hardware.graphics.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    variant = ",";
    options = "grp:alt_shift_toggle"; # Alt+Shift to switch layouts
  };

  console.keyMap = "us";

  networking = {
    networkmanager.enable = true;
    hostName = "freedompc";
  };

  environment.systemPackages = with pkgs; [wget vim];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

  powerManagement.powertop.enable = true;
  programs.dconf.enable = true;

  system.stateVersion = "22.05";
}
