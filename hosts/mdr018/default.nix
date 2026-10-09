{repoRoot, ...}: {
  imports = [
    ./hardware-configuration.nix
    "${repoRoot}/modules/nixos/common"
    "${repoRoot}/modules/nixos/desktop"
    "${repoRoot}/modules/nixos/physical.nix"
    "${repoRoot}/modules/nixos/users/andriano"
    "${repoRoot}/modules/nixos/optional/systemd-boot.nix"
    "${repoRoot}/modules/nixos/optional/docker.nix"
    "${repoRoot}/modules/nixos/optional/throne.nix"
    "${repoRoot}/modules/nixos/optional/searxng.nix"
    "${repoRoot}/modules/nixos/optional/qemu.nix"
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
