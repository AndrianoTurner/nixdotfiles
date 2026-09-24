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
    ../../modules/nixos/optional/searxng.nix
    ../../modules/nixos/optional/qemu.nix
  ];

  home-manager.users.andriano = import ./home.nix;

  nixpkgs.config.allowUnfree = true;

  hardware.graphics.enable = true;

  networking = {
    useDHCP = false;
    interfaces = {
      enp2s0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "172.16.20.2";
            prefixLength = 20;
          }
        ];
      };
    };

    defaultGateway = "172.16.16.1";
    nameservers = ["172.16.0.101"];
    hostName = "mdr018";

    extraHosts = ''
      127.0.0.1 example.com
    '';
  };

  system.stateVersion = "25.05";
}
