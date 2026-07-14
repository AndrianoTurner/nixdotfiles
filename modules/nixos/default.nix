{
  common = import ./common/global;

  users = {
    andriano = import ./users/andriano;
  };

  docker = import ./optional/docker.nix;
  firewall = import ./optional/firewall.nix;
  grub-boot = import ./optional/grub-boot.nix;
  l2tp = import ./optional/l2tp.nix;
  pipewire = import ./optional/pipewire.nix;
  steam = import ./optional/steam.nix;
  systemd-boot = import ./optional/systemd-boot.nix;
  throne = import ./optional/throne.nix;
}
