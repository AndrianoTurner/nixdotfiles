{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/users/andriano
    ../common/optional/pipewire.nix
    ../common/optional/systemd-boot.nix
    ../common/optional/docker.nix
    ../common/optional/throne.nix
    ../common/optional/l2tp.nix
    ../common/optional/firewall.nix
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
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # use proprietary kernel module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      nvidiaBusId = "PCI:1@0:0:0";
      amdgpuBusId = "PCI:65@0:0:0"; # If you have an AMD iGPU
    };
  };

  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  hardware.graphics.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    variant = ",";
    options = "grp:alt_shift_toggle"; # Alt+Shift to switch layouts
  };

  console.keyMap = "us";

  networking = {
    networkmanager.enable = true;
    hostName = "freedompc";

    extraHosts = ''
      127.0.0.1 example.com 
    '';
  };

  environment.systemPackages = with pkgs; [
    wget
    vim
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    kernelParams = [ "usbcore.autosuspend=-1" ];
  };

  powerManagement.powertop.enable = true;
  programs.dconf.enable = true;

  system.stateVersion = "22.05";
}
