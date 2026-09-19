{config, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common
    ../../modules/nixos/desktop
    ../../modules/nixos/physical.nix
    ../../modules/nixos/users/andriano
    ../../modules/nixos/optional/systemd-boot.nix
    ../../modules/nixos/optional/docker.nix
    ../../modules/nixos/optional/throne.nix
    ../../modules/nixos/optional/steam.nix
  ];

  home-manager.users.andriano = import ./home.nix;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "595.99.02";
      sha256_64bit = "sha256-6HR3lYv3YwcFSTJL1a1slI66btIQ5EAFs+/4SUD24ew=";
      sha256_aarch64 = "sha256-CCqHZTN2KNOZ4yZp2rDcuRJp9pHfRw47k4m4dWnS/2w=";
      openSha256 = "sha256-T36x/jx8yQ8l3LFp1rZIrTfcSwbGy8YSAvXOUSptpb4=";
      settingsSha256 = "sha256-GYCcnxfKPrTCrsmd25sMyzfC5cqJQJx0c31haooyTYM=";
      persistencedSha256 = "sha256-VyKtF/HdHPQrHHK6opSO69M72LmnGZtauuchj9uuje8=";
    };

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

  networking = {
    hostName = "freedompc";

    extraHosts = ''
      127.0.0.1 example.com
    '';
  };

  system.stateVersion = "22.05";
}
