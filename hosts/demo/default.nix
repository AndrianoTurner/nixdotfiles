{options, ...}: {
  imports = [
    ../../modules/nixos/common
    ../../modules/nixos/desktop
    ../../modules/nixos/users/demo
  ];

  home-manager.users.demo = import ./home.nix;

  # The VM shares the host's Nix store read-only, so Home Manager cannot build
  # a mutable per-user profile during activation. Put the home packages in the
  # NixOS-managed per-user profile and include them in the VM closure instead.
  home-manager.useUserPackages = true;

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
    qemu.options = [
      # Niri requires a render-capable DRM device. QEMU's default Bochs VGA
      # only provides a display device, so the greeter works but Niri cannot
      # allocate a renderer after login.
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
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
