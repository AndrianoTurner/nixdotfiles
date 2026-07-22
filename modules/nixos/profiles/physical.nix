{pkgs, ...}: {
  hardware.bluetooth.enable = true;

  services = {
    openssh.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

  nix.settings.max-jobs = 1;

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    kernelParams = ["usbcore.autosuspend=-1"];
  };

  powerManagement.powertop.enable = true;
}
