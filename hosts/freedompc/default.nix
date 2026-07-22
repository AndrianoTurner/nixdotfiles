{
  pkgs,
  config,
  outputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    outputs.nixosModules.common
    outputs.nixosModules.primary-user
    outputs.nixosModules.profiles.workstation
    outputs.nixosModules.profiles.physical
    outputs.nixosModules.profiles.personal
    outputs.nixosModules.systemd-boot
    outputs.nixosModules.docker
    outputs.nixosModules.throne
    outputs.nixosModules.steam
  ];

  myConfig.primaryUser = {
    name = "andriano";
    homeModule = outputs.homeManagerModules.hosts.freedompc;
  };

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
