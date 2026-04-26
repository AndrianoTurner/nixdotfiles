{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/users/andriano
    ../common/optional/pipewire.nix
    ../common/optional/systemd-boot.nix
    ../common/optional/docker.nix
  ];
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.openssh.enable = true;
  networking = {
    networkmanager.enable = true;
    hostName = "freedompc";
  };

  environment.systemPackages = with pkgs; [wget vim];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

  powerManagement.powertop.enable = true;
  programs.dconf.enable = true;

  system.stateVersion = "22.05";
}
