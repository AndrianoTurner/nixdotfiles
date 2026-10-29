{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "uas"
      "usbhid"
      "sd_mod"
    ];
    initrd.kernelModules = ["amdgpu"];
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];

    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.useDHCP = lib.mkDefault true;

  # disko derives swapDevices from the disk layout, and this layout has no swap
  # partition, so its empty list would override physical.nix's /swapfile default.
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  services = {
    power-profiles-daemon.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
