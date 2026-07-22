{inputs}: {
  base = import ./andriano/global;

  cli = import ./andriano/features/cli;

  desktop = {
    imports = [
      inputs.niri.homeModules.config
      inputs.zen-browser.homeModules.default
      inputs.noctalia.homeModules.default
      ./andriano/features/desktop
    ];
  };

  personal = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      ./andriano/personal
    ];
  };

  profiles = {
    public = {outputs, ...}: {
      imports = [
        outputs.homeManagerModules.base
        outputs.homeManagerModules.cli
        outputs.homeManagerModules.desktop
      ];
    };

    personal = {outputs, ...}: {
      imports = [
        outputs.homeManagerModules.profiles.public
        outputs.homeManagerModules.personal
      ];
    };
  };

  hosts = {
    freedompc = import ./andriano/freedompc.nix;
    homepc = import ./andriano/homepc.nix;
    mdr018 = import ./andriano/mdr018.nix;
    demo = import ./andriano/demo.nix;
  };
}
