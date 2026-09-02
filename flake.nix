{
  description = "Andriano's NixOS configurations";

  # nixConfig = {
  #   extra-substituters = ["https://noctalia.cachix.org" "https://mirror.yandex.ru/nixos"];
  #   extra-trusted-public-keys = [
  #     "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
  #   ];
  # };

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
    # The cachix branch follows the newest v5 revision already available in
    # Noctalia's binary cache. Do not make its nixpkgs input follow ours: that
    # would change the derivation hash and bypass the cache.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpaper-bank = {
      url = "github:JaKooLit/Wallpaper-Bank";
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
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # Personal Laptop
      freedompc = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          outputs = self.outputs;
        };
        modules = [
          ./hosts/freedompc
        ];
      };

      homepc = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          outputs = self.outputs;
        };
        modules = [
          ./hosts/homepc
        ];
      };

      mdr018 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          outputs = self.outputs;
        };
        modules = [
          ./hosts/mdr018
        ];
      };

      # Public, secret-free QEMU demo
      demo = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          outputs = self.outputs;
        };
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
