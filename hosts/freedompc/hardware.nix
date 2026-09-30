{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "uas"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    initrd.kernelModules = [];
    kernelModules = ["kvm-amd"];
    kernelParams = ["usbcore.autosuspend=-1"];
  };

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-uuid/0664c5db-4dc9-475b-8b6b-29bd6d467150";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-uuid/B813-ED79";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
