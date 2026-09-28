{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ../../modules/nixos/common
    ../../modules/nixos/desktop
    ../../modules/nixos/physical.nix
    ../../modules/nixos/users/andriano
    ../../modules/nixos/optional/systemd-boot.nix
  ];

  home-manager.users.andriano = import ./home.nix;

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = ["kvm-amd"];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["amdgpu"];

  # physical.nix provides an 8 GiB swapfile for ext4 hosts. Chodum uses the
  # stable LVM swap LV from disko so hibernation can resume reliably.
  swapDevices = lib.mkForce [
    {
      device = "/dev/pool/swap";
    }
  ];
  boot.resumeDevice = "/dev/pool/swap";

  networking.hostName = "chodum";
  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "26.05";
}
