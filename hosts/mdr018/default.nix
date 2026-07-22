{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    outputs.nixosModules.common
    outputs.nixosModules.primary-user
    outputs.nixosModules.profiles.workstation
    outputs.nixosModules.profiles.physical
    outputs.nixosModules.profiles.personal
    outputs.nixosModules.systemd-boot
    outputs.nixosModules.docker
    outputs.nixosModules.throne
  ];

  myConfig.primaryUser = {
    name = "andriano";
    homeModule = outputs.homeManagerModules.hosts.mdr018;
  };

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
