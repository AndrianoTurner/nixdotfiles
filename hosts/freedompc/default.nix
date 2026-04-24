{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.framework-13-7040-amd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/andriano

    ../common/optional/peripherals.nix
    ../common/optional/regreet.nix
    ../common/optional/pipewire.nix
    ../common/optional/quietboot.nix

    ../common/optional/wireless.nix
  ];

  networking = {
    hostName = "freedompc";
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

  powerManagement.powertop.enable = true;
  programs.dconf.enable = true;

  system.stateVersion = "22.05";
}

