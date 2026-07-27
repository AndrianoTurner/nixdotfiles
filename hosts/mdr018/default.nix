{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common
    ../../modules/nixos/desktop
    ../../modules/nixos/physical.nix
    ../../modules/nixos/users/andriano
    ../../modules/nixos/optional/systemd-boot.nix
    ../../modules/nixos/optional/docker.nix
    ../../modules/nixos/optional/throne.nix
  ];

  home-manager.users.andriano = import ./home.nix;

  nixpkgs.config.allowUnfree = true;

  hardware.graphics.enable = true;

  networking = {
    hostName = "mdr018";

    extraHosts = ''
      127.0.0.1 example.com
    '';
  };

  system.stateVersion = "25.05";
}
