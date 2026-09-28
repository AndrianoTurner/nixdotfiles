{
  pkgs,
  lib,
  ...
}: {
  hardware = {
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
  };

  services = {
    openssh.enable = true;
    upower.enable = true;
  };

  swapDevices = lib.mkDefault [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    # Compressed RAM cache.
    zswap = {
      enable = false;
      compressor = "zstd";
      maxPoolPercent = 20;
      shrinkerEnabled = true;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };
}
