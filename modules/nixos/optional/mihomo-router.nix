{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.mihomo-router;
  # Our own crate at cfg.logLevel, then any extra RUST_LOG directives.
  rustLog = lib.concatStringsSep "," (["mihomo_router=${cfg.logLevel}"] ++ cfg.logFilters);
in {
  options.services.mihomo-router = {
    enable = lib.mkEnableOption "the mihomo exit-country controller";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mihomo-router;
      defaultText = lib.literalExpression "pkgs.mihomo-router";
      description = "mihomo-router package to run.";
    };

    api = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:9090";
      description = ''
        Mihomo REST API base. The binary refuses anything that is not a
        `http://127.0.0.1:<port>` URL, so this cannot point off-host.
      '';
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/run/secrets/mihomo-api";
      description = ''
        File holding the Mihomo API secret, for a controller with a
        `secret:` set. Omit when the controller port has none. The file must be
        readable by the service user (see `dynamicUser`/`user`).
      '';
    };

    provider = lib.mkOption {
      type = lib.types.str;
      default = "vless";
      description = ''
        Name of the mihomo proxy-provider whose nodes are verified and
        selected. `mihomo.nix` names its provider after this value.
      '';
    };

    interval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 60;
      description = "Seconds between reconciliation passes.";
    };

    lanes = lib.mkOption {
      type = lib.types.ints.between 1 64;
      default = 8;
      description = ''
        Number of probe lanes. `mihomo.nix` generates the matching
        `PROBE-<n>` select groups and probe listeners from this value, so the
        two sides cannot drift apart.
      '';
    };

    probePort = lib.mkOption {
      type = lib.types.port;
      default = 17800;
      description = "First probe listener port; lane `<n>` uses `probePort + n`.";
    };

    stateDirectory = lib.mkOption {
      type = lib.types.str;
      default = "mihomo-router";
      description = ''
        systemd `StateDirectory` name for the verification cache. Keep the
        default unless another instance needs its own cache.
      '';
    };

    logLevel = lib.mkOption {
      type = lib.types.enum ["trace" "debug" "info" "warn" "error"];
      default = "info";
      description = ''
        Log level for mihomo-router itself (the `mihomo_router` RUST_LOG
        target). `debug` logs every lane, verdict, latency and API call.
      '';
    };

    logFilters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["reqwest=warn" "hyper=warn"];
      description = ''
        Extra RUST_LOG directives appended after `logLevel`, e.g. to silence
        dependency noise or to debug just the API client.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = ''
        Extra environment variables for the service. `RUST_LOG` is derived from
        `logLevel`/`logFilters` but can be overridden here.
      '';
    };

    restart = lib.mkOption {
      type = lib.types.str;
      default = "always";
      description = "systemd `Restart=` policy.";
    };

    restartSec = lib.mkOption {
      type = lib.types.str;
      default = "10s";
      description = "systemd `RestartSec=` value.";
    };

    dynamicUser = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run as a transient systemd user. Disable together with `user`/`group`
        when the controller must read a root-owned secret file.
      '';
    };

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Service user when `dynamicUser` is off.";
    };

    group = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Service group when `dynamicUser` is off.";
    };

    extraServiceConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = ''
        Extra `systemd.services.mihomo-router.serviceConfig` attributes. These
        win over the module's own hardening and restart settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.dynamicUser && (cfg.user != null || cfg.group != null));
        message = "services.mihomo-router: set user/group only when dynamicUser = false";
      }
      {
        assertion = cfg.tokenFile == null || !cfg.dynamicUser;
        message = ''
          services.mihomo-router: a secret token file is not readable by a
          DynamicUser; set dynamicUser = false and pick user/group that can
          read tokenFile'';
      }
    ];

    systemd.services.mihomo-router = {
      description = "Mihomo exit-country controller";
      wantedBy = ["multi-user.target"];
      wants = ["mihomo.service"];
      after = ["mihomo.service"];

      environment = {RUST_LOG = rustLog;} // cfg.environment;

      serviceConfig =
        {
          ExecStart = lib.concatStringsSep " " (let
            args = [
              "${cfg.package}/bin/mihomo-router"
              "--api ${cfg.api}"
              "--provider ${cfg.provider}"
              "--state /var/lib/${cfg.stateDirectory}"
              "--interval ${toString cfg.interval}"
              "--lanes ${toString cfg.lanes}"
              "--probe-port ${toString cfg.probePort}"
            ];
          in
            args
            ++ lib.optional (cfg.tokenFile != null) "--token-file ${cfg.tokenFile}");
          StateDirectory = cfg.stateDirectory;
          Restart = cfg.restart;
          RestartSec = cfg.restartSec;

          # Backstop: the controller is a background helper and must never
          # compete with interactive work.
          MemoryMax = "64M";
          CPUQuota = "20%";
          Nice = 10;
          IOSchedulingClass = "idle";

          # Loopback API and HTTPS exits are all it needs.
          RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          NoNewPrivileges = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictNamespaces = true;
          LockPersonality = true;
          RestrictSUIDSGID = true;
          MemoryDenyWriteExecute = true;
        }
        // lib.optionalAttrs cfg.dynamicUser {DynamicUser = true;}
        // lib.optionalAttrs (cfg.user != null) {User = cfg.user;}
        // lib.optionalAttrs (cfg.group != null) {Group = cfg.group;}
        // cfg.extraServiceConfig;
    };
  };
}
