# Secret-free configuration shared by every host.
{
  inputs,
  outputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./fish.nix
    ./nix.nix
    ./security.nix
  ];

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
  };

  time.timeZone = "Europe/Moscow";

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs;
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  # Cleanup stuff included by default
  services.speechd.enable = false;
}
