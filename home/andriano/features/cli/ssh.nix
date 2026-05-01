{config, ...}: {
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "gitea-internal" = {
        host = "10.0.0.53";
        user = "git";
        port = 222;
        identityFile = config.sops.secrets."ssh/github".path;
      };

      "proxmox" = {
        host = "10.0.0.50";
        user = "root";
        port = 22;
        identityFile = config.sops.secrets."ssh/proxmox".path;
      };

      "gitlab.internal.madrigal.ru" = {
        user = "git";
        identityFile = config.sops.secrets."ssh/gitlab-work".path;
      };

      "github.com" = {
        user = "git";
        identityFile = config.sops.secrets."ssh/github".path;
      };
    };
  };
}
