{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
    nerd-fonts._3270
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    nerd-fonts.bigblue-terminal
    nerd-fonts.hack
    nerd-fonts.departure-mono
  ];
}
