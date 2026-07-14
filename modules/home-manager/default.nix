{
  andriano = import ./andriano/global;
  cli = import ./andriano/features/cli;
  desktop = import ./andriano/features/desktop;

  hosts = {
    freedompc = import ./andriano/freedompc.nix;
    homepc = import ./andriano/homepc.nix;
    mdr018 = import ./andriano/mdr018.nix;
  };
}
