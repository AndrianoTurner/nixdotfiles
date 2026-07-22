{
  pkgs,
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
    outputs.nixosModules.grub-boot
    outputs.nixosModules.docker
    outputs.nixosModules.throne
  ];

  myConfig.primaryUser = {
    name = "andriano";
    homeModule = outputs.homeManagerModules.hosts.homepc;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
  hardware.amdgpu.opencl.enable = true;

  networking = {
    hostName = "homepc";
    extraHosts = ''
      127.0.0.1 example.com
    '';
  };

  environment.systemPackages = with pkgs; [
    #amd
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    rocmPackages.clr
    rocmPackages.rocsolver
    rocmPackages.rocblas
    clinfo
    cifs-utils
  ];

  system.stateVersion = "25.05";
}
