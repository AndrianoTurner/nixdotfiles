{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware.nix
    ../../modules/nixos/common
    ../../modules/nixos/desktop
    ../../modules/nixos/physical.nix
    ../../modules/nixos/users/andriano
    ../../modules/nixos/optional/throne.nix
    ../../modules/nixos/optional/systemd-boot.nix
  ];

  home-manager.users.andriano = import ./home.nix;

  networking.hostName = "chodum";

  system.stateVersion = "26.05";
}
