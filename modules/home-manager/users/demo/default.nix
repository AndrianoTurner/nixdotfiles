{options, ...}: {
  imports = [
    ../../shared
    ../../features/cli
    ../../features/desktop
  ];

  home.stateVersion = "26.05";

  assertions = [
    {
      assertion = !(options ? sops);
      message = "The demo Home Manager configuration must not import sops-nix";
    }
  ];
}
