{pkgs, ...}: {
  imports = [
    ./noctalia-greeter.nix
    ./niri.nix
    ../optional/firewall.nix
    ../optional/pipewire.nix
  ];

  fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
  networking.networkmanager.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    variant = ",";
    options = "grp:alt_shift_toggle";
  };
  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    wget
    vim
  ];

  programs.dconf.enable = true;
}
