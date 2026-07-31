{
  lib,
  pkgs,
  ...
}: let
  bindAddress = "127.0.0.1";
  port = 8888;
  proxyUrl = "http://172.16.0.41:3128";
  secretFile = "/var/lib/searx/secret.env";
in {
  services.searx = {
    enable = true;

    # The built-in HTTP server is sufficient for a loopback-only API.
    configureUwsgi = false;
    configureNginx = false;
    openFirewall = false;

    environmentFile = secretFile;

    settings = {
      use_default_settings = true;

      general = {
        debug = false;
        instance_name = "Local SearXNG";
        enable_metrics = false;
      };

      search = {
        safe_search = 0;
        autocomplete = "";

        # pi-web-access consumes the JSON API. HTML remains useful for
        # testing the local instance from a browser.
        formats = [
          "html"
          "json"
        ];
      };

      server = {
        bind_address = bindAddress;
        inherit port;
        secret_key = "$SEARXNG_SECRET";
        limiter = false;
        public_instance = false;
        image_proxy = false;
        method = "GET";
      };

      outgoing = {
        request_timeout = 10.0;
        max_request_timeout = 20.0;
        pool_connections = 100;
        pool_maxsize = 20;
        enable_http2 = true;

        # Remove this block when the host has direct outbound access.
        proxies."all://" = [proxyUrl];
      };

      plugins = {
        "searx.plugins.calculator.SXNGPlugin".active = true;
        "searx.plugins.hash_plugin.SXNGPlugin".active = true;
        "searx.plugins.unit_converter.SXNGPlugin".active = true;
        "searx.plugins.time_zone.SXNGPlugin".active = true;
        "searx.plugins.tracker_url_remover.SXNGPlugin".active = true;
      };
    };
  };

  # Generate the mandatory SearXNG cryptographic secret once at runtime.
  # It never enters the Nix store.
  systemd.services.searx-secret = {
    description = "Generate the local SearXNG secret";
    before = ["searx-init.service"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "searx";
      Group = "searx";
      StateDirectory = "searx";
      StateDirectoryMode = "0700";
    };

    script = ''
      set -eu

      if [ ! -s ${lib.escapeShellArg secretFile} ]; then
        umask 077
        printf 'SEARXNG_SECRET=%s\n' \
          "$(${lib.getExe pkgs.openssl} rand -hex 32)" \
          > ${lib.escapeShellArg secretFile}
      fi

      chmod 0600 ${lib.escapeShellArg secretFile}
    '';
  };

  systemd.services.searx-init = {
    requires = ["searx-secret.service"];
    after = ["searx-secret.service"];
  };

  systemd.services.searx.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "2s";
  };
}
