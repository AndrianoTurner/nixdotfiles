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

      security.polkit = {
        enable = true;
        extraConfig = lib.mkIf (cfg.tunMode.enable && !cfg.tunMode.setuid && config.services.resolved.enable) ''
          polkit.addRule(function(action, subject) {
            const allowedActionIds = [
              "org.freedesktop.resolve1.revert",
              "org.freedesktop.resolve1.set-domains",
              "org.freedesktop.resolve1.set-default-route",
              "org.freedesktop.resolve1.set-dns-servers"
            ];

            if (allowedActionIds.indexOf(action.id) !== -1) {
              try {
                var parentPid = polkit.spawn(["${lib.getExe' pkgs.procps "ps"}", "-o", "ppid=", subject.pid]).trim();
                var parentCap = polkit.spawn(["${lib.getExe' pkgs.libcap "getpcaps"}", parentPid]).trim();
                if (parentCap.includes("cap_net_admin") && parentCap.includes("cap_net_raw")) {
                  return polkit.Result.YES;
                }
              } catch (e) {
                return polkit.Result.NOT_HANDLED;
              }
            }

            return polkit.Result.NOT_HANDLED;
          });
        '';
      };
    })
  ];
}
