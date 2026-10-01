{
  config,
  inputs,
  repoRoot,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware.nix
    "${repoRoot}/modules/nixos/common"
    "${repoRoot}/modules/nixos/desktop"
    "${repoRoot}/modules/nixos/physical.nix"
    "${repoRoot}/modules/nixos/users/andriano"
    "${repoRoot}/modules/nixos/optional/l2tp.nix"
    "${repoRoot}/modules/nixos/optional/systemd-boot.nix"
    "${repoRoot}/modules/nixos/optional/docker.nix"
    "${repoRoot}/modules/nixos/optional/throne.nix"
    "${repoRoot}/modules/nixos/optional/steam.nix"
  ];

  home-manager.users.andriano = import ./home.nix;
  hardware = {
    graphics.enable = true;
    nvidia = {
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
  };

  services = {
    power-profiles-daemon.enable = true;
    xserver.videoDrivers = [
      "amdgpu"
      "nvidia"
    ];
  };

  networking = {
    hostName = "freedompc";

    extraHosts = ''
      127.0.0.1 example.com
    '';
  };

  system.stateVersion = "26.05";
}
