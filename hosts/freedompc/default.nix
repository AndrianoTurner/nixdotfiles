{config, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common
    ../../modules/nixos/desktop
    ../../modules/nixos/physical.nix
    ../../modules/nixos/users/andriano
    ../../modules/nixos/optional/systemd-boot.nix
    ../../modules/nixos/optional/docker.nix
    ../../modules/nixos/optional/throne.nix
    ../../modules/nixos/optional/steam.nix
  ];

  home-manager.users.andriano = import ./home.nix;

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

  networking = {
    hostName = "freedompc";

    extraHosts = ''
      127.0.0.1 example.com
    '';
  };

  system.stateVersion = "22.05";
}
