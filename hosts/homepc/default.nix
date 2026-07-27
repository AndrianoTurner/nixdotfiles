{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common
    ../../modules/nixos/desktop
    ../../modules/nixos/physical.nix
    ../../modules/nixos/users/andriano
    ../../modules/nixos/optional/grub-boot.nix
    ../../modules/nixos/optional/docker.nix
    ../../modules/nixos/optional/throne.nix
  ];

  home-manager.users.andriano = import ./home.nix;

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
