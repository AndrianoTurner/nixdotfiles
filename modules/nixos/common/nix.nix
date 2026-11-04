{
  inputs,
  lib,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  nix = {
    settings = {
      max-jobs = 2;
      cores = 1;
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      warn-dirty = false;
      system-features = [
        "kvm"
        "big-parallel"
        "nixos-test"
      ];
      # Lower numbers win; prefer the mirror over the upstream cache.
      substituters = [
        "https://mirror.yandex.ru/nixos/?priority=10"
        "http://mirror.yandex.ru/nixos/?priority=20"
        "https://cache.nixos.org/?priority=40"
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];

      flake-registry = ""; # Disable global flake registry
    };

    optimise = {
      automatic = true;
      persistent = true;
      randomizedDelaySec = "300";
      dates = ["12:00"];
    };

    # Add each flake input as a registry and nix_path
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };
}
