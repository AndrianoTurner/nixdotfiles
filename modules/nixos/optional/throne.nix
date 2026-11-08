{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.throne;
in {
  # The stable NixOS module targets Throne's old `Core` binary. Keep the same
  # option interface locally while matching the package layout from unstable.
  disabledModules = ["programs/throne.nix"];

  options.programs.throne = {
    enable = lib.mkEnableOption "Throne, a GUI proxy configuration manager";
    package = lib.mkPackageOption pkgs.unstablePkgs "throne" {};

    tunMode = {
      enable = lib.mkEnableOption "TUN mode of Throne";
      setuid = lib.mkEnableOption ''
        setting the setuid bit for ThroneCore instead of using capabilities
      '';
    };
  };

  config = lib.mkMerge [
    {
      programs.throne = {
        enable = true;
        package = pkgs.unstablePkgs.throne;
        tunMode.enable = true;
      };
    }

    (lib.mkIf cfg.enable {
      environment.systemPackages = [cfg.package];

      security.wrappers.ThroneCore = lib.mkIf cfg.tunMode.enable {
        source = "${cfg.package}/share/throne/ThroneCore";
        owner = "root";
        group = "root";
        setuid = lib.mkIf cfg.tunMode.setuid true;
        capabilities = lib.mkIf (!cfg.tunMode.setuid) "cap_net_admin,cap_net_raw,cap_net_bind_service,cap_sys_ptrace,cap_dac_read_search+ep";
      };
    })
  ];
}
