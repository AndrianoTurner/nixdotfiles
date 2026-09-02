{ ... }: {
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 2080 ];
  };
}
