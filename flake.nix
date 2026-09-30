{
  description = "Andriano's NixOS configurations";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-25.url = "github:nixos/nixpkgs/nixos-25.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpaper-bank = {
      url = "github:makccr/wallpapers?shallow=1";
      flake = false;
    };

    pi = {
      url = "github:lukasl-dev/pi.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    repoRoot = ./.;

    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;

    specialArgs = {
      inherit inputs;
      inherit repoRoot;
      outputs = self.outputs;
    };
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    checks = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      format =
        pkgs.runCommand "format-check" {
          nativeBuildInputs = [pkgs.alejandra];
        } ''
          alejandra --check ${self}
          touch $out
        '';
    });

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # Personal Laptop
      freedompc = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/freedompc
        ];
      };

      homepc = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/homepc
        ];
      };

      mdr018 = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/mdr018
        ];
      };

      chodum = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/chodum
        ];
      };

      # Public, secret-free QEMU demo
      demo = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/demo
        ];
      };
    };

    apps = forAllSystems (_system: {
      demo = {
        type = "app";
        program = "${self.nixosConfigurations.demo.config.system.build.vm}/bin/run-demo-vm";
        meta.description = "Run the secret-free NixOS desktop demo VM";
      };
    });
  };
}
