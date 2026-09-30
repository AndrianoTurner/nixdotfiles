{inputs, repoRoot, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware.nix
    "${repoRoot}/modules/nixos/common"
    "${repoRoot}/modules/nixos/desktop"
    "${repoRoot}/modules/nixos/physical.nix"
    "${repoRoot}/modules/nixos/users/andriano"
    "${repoRoot}/modules/nixos/optional/l2tp.nix"
    "${repoRoot}/modules/nixos/optional/throne.nix"
    "${repoRoot}/modules/nixos/optional/systemd-boot.nix"
  ];

  home-manager.users.andriano = import ./home.nix;

  networking.hostName = "chodum";

  system.stateVersion = "26.05";
}
