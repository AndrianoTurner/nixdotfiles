{...}: {
  boot = {
    initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
    initrd.kernelModules = ["amdgpu"];
    kernelModules = ["kvm-amd"];
    resumeDevice = "/dev/pool/swap";
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  # physical.nix provides an 8 GiB swapfile for ext4 hosts. Chodum uses the
  # stable LVM swap LV from disko so hibernation can resume reliably.
  swapDevices = [
    {
      device = "/dev/pool/swap";
    }
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["amdgpu"];
}
