{
  options,
  outputs,
  ...
}: {
  imports = [outputs.homeManagerModules.profiles.public];

  home.stateVersion = "26.05";

  assertions = [
    {
      assertion = !(options ? sops);
      message = "The demo Home Manager profile must not import sops-nix";
    }
  ];
}
