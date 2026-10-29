{
  pkgs,
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
    "${repoRoot}/modules/nixos/optional/grub-boot.nix"
    "${repoRoot}/modules/nixos/optional/docker.nix"
    "${repoRoot}/modules/nixos/optional/throne.nix"
    "${repoRoot}/modules/nixos/optional/l2tp.nix"
    "${repoRoot}/modules/nixos/optional/mihomo.nix"
    "${repoRoot}/modules/nixos/optional/yggdrasil.nix"
    "${repoRoot}/modules/nixos/optional/qemu.nix"
  ];

  home-manager.users.andriano = import ./home.nix;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
  hardware.amdgpu.opencl.enable = true;

  networking = {
    hostName = "homepc";
    extraHosts = ''
      127.0.0.1 example.com
    '';
  };

  environment.systemPackages = with pkgs; [
    #amd
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    rocmPackages.clr
    clinfo
    cifs-utils
  ];

  system.stateVersion = "25.05";
}
