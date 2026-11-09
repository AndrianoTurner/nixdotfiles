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
      connect-timeout = 10;
      stalled-download-timeout = 30;
      download-attempts = 2;
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
