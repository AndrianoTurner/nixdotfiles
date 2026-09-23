{pkgs, ...}: {
  hardware.bluetooth.enable = true;
  hardware.enableRedistributableFirmware = true;

  services = {
    openssh.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    # Scheduler
    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    kernelParams = ["usbcore.autosuspend=-1"];
    # Compressed RAM cache.
    zswap = {
      enable = true;
      compressor = "zstd";
      maxPoolPercent = 20;
      shrinkerEnabled = true;
    };
  };

  zramSwap.enable = false;

  powerManagement.powertop.enable = true;
}
