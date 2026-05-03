{
  description = "Rust dev environment with rust-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {inherit system overlays;};

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
            "rustfmt"
          ];
          # targets = [ "wasm32-unknown-unknown" ];  # Uncomment if needed
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Rust
            rustToolchain

            # Build essentials
            pkg-config
            openssl
            zlib

            # Helpful CLI tools
            eza
            fd
            ripgrep
            just # task runner

            # Optional: sccache for faster builds
            # sccache
          ];

          # Environment variables
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";

          # Optional: enable sccache
          # RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";

          shellHook = ''
            echo "🦀 Rust $(rustc --version) ready"
            echo "📦 Cargo $(cargo --version) ready"
            alias ls=eza
            alias find=fd
          '';
        };
      }
    );
}
