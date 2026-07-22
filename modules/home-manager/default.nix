{inputs}: {
  andriano = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      ./andriano/global
    ];
  };

  cli = import ./andriano/features/cli;

  desktop = {
    imports = [
      inputs.zen-browser.homeModules.default
      inputs.noctalia.homeModules.default
      ./andriano/features/desktop
    ];
  };

  hosts = {
    freedompc = import ./andriano/freedompc.nix;
    homepc = import ./andriano/homepc.nix;
    mdr018 = import ./andriano/mdr018.nix;
  };
}
