{
  config,
  lib,
  pkgs,
  repoRoot,
  ...
}: let
  cfg = config.services.mihomo-router;
  workVpn = config.networking.networkmanager.ensureProfiles.profiles.mdr or null;
  mihomo-tun = pkgs.writeShellApplication {
    name = "mihomo-tun";

    runtimeInputs = with pkgs; [
      coreutils
      curl
      jq
    ];

    text = ''
      set -euo pipefail

      api="http://127.0.0.1:9090"
      # mihomo's default tun device; the generated config leaves it unset.
      device=Meta
      args=(--silent --show-error --fail-with-body --noproxy '*')

      if [[ -n "''${MIHOMO_SECRET:-}" ]]; then
        args+=(-H "Authorization: Bearer $MIHOMO_SECRET")
      fi

      get_state() {
        curl "''${args[@]}" "$api/configs" |
          jq -r 'if (.tun.enable | type) == "boolean"
                 then .tun.enable
                 else error("TUN state unavailable")
                 end'
      }

      patch() { # $1 = true|false
        curl "''${args[@]}" \
          -X PATCH \
          -H "Content-Type: application/json" \
          -d "{\"tun\":{\"enable\":$1}}" \
          "$api/configs" >/dev/null
      }

      # mihomo flips .tun.enable before the device is up and before it is gone.
      # Enabling inside that window drops the change and logs "device or
      # resource busy", so wait for the flag and the device to agree.
      settled() { # $1 = true|false
        local state
        for _ in {1..50}; do
          state="$(get_state 2>/dev/null || true)"
          if [[ "$state" == "$1" ]]; then
            if [[ "$1" == true ]] && [[ -e "/sys/class/net/$device" ]]; then return 0; fi
            if [[ "$1" == false ]] && [[ ! -e "/sys/class/net/$device" ]]; then return 0; fi
          fi
          sleep 0.1
        done
        return 1
      }

      current="$(get_state)"

      case "''${1:-status}" in
        on)
          desired=true
          ;;
        off)
          desired=false
          ;;
        toggle)
          if [[ "$current" == true ]]; then
            desired=false
          else
            desired=true
          fi
          ;;
        status)
          if [[ "$current" == true ]] && [[ ! -e "/sys/class/net/$device" ]]; then
            echo "TUN: true but $device is missing"
            exit 1
          fi
          echo "TUN: $current"
          exit 0
          ;;
        *)
          echo "Usage: mihomo-tun {on|off|toggle|status}" >&2
          exit 2
          ;;
      esac

      if [[ "$current" == "$desired" ]] && settled "$desired"; then
        echo "TUN already $current"
        exit 0
      fi

      # A teardown may still be in flight; let it finish before enabling.
      if [[ "$desired" == true ]]; then
        settled false || true
      fi

      patch "$desired"
      if ! settled "$desired"; then
        # A wedged core only recovers through a restart; it re-reads the config
        # on disk, so the patch is replayed afterwards.
        curl "''${args[@]}" -X POST "$api/restart" >/dev/null
        sleep 2
        patch "$desired"
        settled "$desired" || {
          echo "mihomo-tun: TUN did not become $desired" >&2
          exit 1
        }
      fi

      echo "TUN: $(get_state)"
    '';
  };
  lanes = lib.range 0 (cfg.lanes - 1);
  probeGroup = n:
    "  - name: PROBE-${toString n}\n"
    + "    type: select\n"
    + "    proxies: [REJECT]\n"
    + "    use: [${cfg.provider}]\n";
  probeListener = n:
    "  - name: probe-${toString n}\n"
    + "    type: mixed\n"
    + "    listen: 127.0.0.1\n"
    + "    port: ${toString (cfg.probePort + n)}\n"
    + "    proxy: PROBE-${toString n}\n"
    + "    udp: false\n";
in {
  imports = [./mihomo-router.nix];

  sops.secrets."mihomo-subscription" = {
    sopsFile = "${repoRoot}/secrets/system/mihomo.yaml";
  };

  services.mihomo = {
    enable = true;
    # SOCKS5 + HTTP on one localhost port. TUN stays off until `mihomo-tun on`
    # flips it at runtime over the REST API. mihomo owns the subscription and
    # the connections; mihomo-router owns eligibility.
    configFile = config.sops.templates."mihomo.yaml".path;
    # CAP_NET_ADMIN + tun device access; without it the API rejects enable.
    tunMode = true;
  };

  # `mihomo-tun {on|off|toggle|status}`
  environment.systemPackages = [mihomo-tun];

  services.mihomo-router.enable = true;

  systemd.services.mihomo = {
    after = ["sops-nix.service"];
    serviceConfig = {
      Restart = "always";
      RestartSec = "3s";
    };
    # Go sizes its scheduler and per-P allocation arenas to GOMAXPROCS; a home
    # proxy does not need one thread per core.
    environment.GOMAXPROCS = "4";
  };

  # Static config: one select group the controller drives over the REST API,
  # plus one probe group and listener per lane. Both sides read `lanes` and
  # `probePort` from services.mihomo-router, so they cannot drift apart.
  sops.templates."mihomo.yaml" = {
    content =
      ''
        mixed-port: 7890
        allow-lan: false
        mode: rule
        log-level: warning
        # No working IPv6 uplink here: AAAA dials would only waste time.
        ipv6: false
        unified-delay: true
        tcp-concurrent: true

        # Loopback only, no secret: nothing but mihomo-router talks to it.
        external-controller: 127.0.0.1:9090

        # Needed for TUN: hijacked :53 queries land in this resolver.
        dns:
          enable: true
          ipv6: false
      ''
      + lib.optionalString (workVpn != null) (
        "  nameserver-policy:\n"
        + "    \"+.internal.madrigal.ru\": \"172.16.0.101#WORK-VPN\"\n"
      )
      + ''

        tun:
          enable: false
          stack: gvisor
          auto-route: true
          auto-detect-interface: true
          dns-hijack:
            - any:53

      ''
      + lib.optionalString (workVpn != null) ''
        proxies:
          - name: WORK-VPN
            type: direct
            interface-name: ${workVpn.vpn.ifname}
      ''
      + ''

        proxy-providers:
          ${cfg.provider}:
            type: http
            # Fetch before FOREIGN-OUT has nodes; its initial selection is REJECT.
            proxy: DIRECT
            url: "${config.sops.placeholder."mihomo-subscription"}"
            interval: 3600

        proxy-groups:
          - name: FOREIGN-OUT
            type: select
            proxies: [REJECT]
            use: [${cfg.provider}]
      ''
      + lib.optionalString (workVpn != null) (
        "  - name: VPN-UPLINK\n"
        + "    type: select\n"
        + "    proxies: [REJECT]\n"
        + "    use: [${cfg.provider}]\n"
      )
      + lib.concatMapStrings probeGroup lanes
      + ''

        listeners:
      ''
      + lib.concatMapStrings probeListener lanes
      + ''

        rules:
      ''
      + lib.optionalString (workVpn != null) (
        "  - AND,((NETWORK,udp),(OR,((DST-PORT,500),(DST-PORT,4500)))),VPN-UPLINK\n"
        # Mihomo skips an outbound that does not support UDP; never fall through.
        + "  - AND,((NETWORK,udp),(OR,((DST-PORT,500),(DST-PORT,4500)))),REJECT\n"
        + "  - DOMAIN-SUFFIX,internal.madrigal.ru,WORK-VPN\n"
        + "  - IP-CIDR,172.16.0.100/32,WORK-VPN,no-resolve\n"
        + "  - IP-CIDR,172.16.0.101/32,WORK-VPN,no-resolve\n"
        + "  - IP-CIDR,172.16.16.0/20,WORK-VPN,no-resolve\n"
      )
      + "  - MATCH,FOREIGN-OUT\n";
  };
}
