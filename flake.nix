{
  description = "Your new nix config";

  # nixConfig = {
  #   extra-substituters = ["https://noctalia.cachix.org"];
  #   extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
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
    lazyvim.url = "github:pfassina/lazyvim-nix";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs-unstable";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "x86_64-linux"
      ];
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      pkgs-old = import inputs.nixpkgs-25 {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # Personal Laptop
        freedompc = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs pkgs-unstable pkgs-old;
            outputs = self.outputs;
          };
          modules = [
            ./hosts/freedompc
          ];
        };

        homepc = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs pkgs-unstable pkgs-old;
            outputs = self.outputs;
          };
          modules = [
            ./hosts/homepc
          ];
        };

        mdr018 = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs pkgs-unstable pkgs-old;
            outputs = self.outputs;
          };
          modules = [
            ./hosts/mdr018
          ];
        };
      };
    };
}
