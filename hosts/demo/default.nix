{
  options,
  outputs,
  ...
}: {
  imports = [
    outputs.nixosModules.common
    outputs.nixosModules.primary-user
    outputs.nixosModules.profiles.workstation
  ];

  myConfig.primaryUser = {
    name = "demo";
    homeModule = outputs.homeManagerModules.hosts.demo;
  };

  users.users.demo.initialPassword = "demo";

  networking.hostName = "demo";
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.graphics.enable = true;

  # Keep the base configuration evaluable while build-vm replaces this with
  # its persistent ext4 disk and direct-boot setup.
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };
  boot.loader.grub.enable = false;

  virtualisation.vmVariant.virtualisation = {
    memorySize = 4096;
    cores = 4;
    graphics = true;
    resolution = {
      x = 1440;
      y = 900;
    };
  };

  assertions = [
    {
      assertion = !(options ? sops);
      message = "The demo NixOS configuration must not import sops-nix";
    }
  ];

  system.stateVersion = "26.05";
}
