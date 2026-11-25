# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  ilspy = pkgs.callPackage ./ilspy {};
  pi-acp = pkgs.callPackage ./pi-acp {};
  agent-browser-bin = pkgs.callPackage ./agent-browser-bin {};
  mihomo-router = pkgs.callPackage ./mihomo-router {};
}
