{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    networkmanager-l2tp
    networkmanager-strongswan
    networkmanagerapplet
  ];

  services.strongswan.enable = true;

  services.xl2tpd.enable = true;
}
