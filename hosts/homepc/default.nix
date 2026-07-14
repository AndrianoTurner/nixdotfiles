{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    outputs.nixosModules.common
    outputs.nixosModules.users.andriano
    outputs.nixosModules.pipewire
    outputs.nixosModules.grub-boot
    outputs.nixosModules.docker
    outputs.nixosModules.throne
    outputs.nixosModules.l2tp
    outputs.nixosModules.firewall
  ];
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.openssh.enable = true;

  nix.settings.max-jobs = 1;
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192; # Size in Megabytes (8192 = 8GB)
    }
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
  hardware.amdgpu.opencl.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    variant = ",";
    options = "grp:alt_shift_toggle"; # Alt+Shift to switch layouts
  };

  console.keyMap = "us";

  networking = {
    networkmanager.enable = true;
    hostName = "homepc";
    extraHosts = ''
      127.0.0.1 example.com
    '';
  };

  environment.systemPackages = with pkgs; [
    wget
    vim
    #amd
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    rocmPackages.clr
    rocmPackages.rocsolver
    rocmPackages.rocblas
    clinfo
    cifs-utils
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    kernelParams = ["usbcore.autosuspend=-1"];
  };

  powerManagement.powertop.enable = true;
  programs.dconf.enable = true;

  system.stateVersion = "25.05";
}
