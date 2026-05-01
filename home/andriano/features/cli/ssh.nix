{...}: {
programs.ssh = {
  enable = true;

  matchBlocks = {
    "gitea-internal" = {
      host         = "10.0.0.53";
      user         = "git";
      port         = 222;
      identityFile = "/run/secrets/ssh/github";
    };

    "proxmox" = {
      host         = "10.0.0.50";
      user         = "root";
      port         = 22;
      identityFile = "/run/secrets/ssh/proxmox";
    };

    "gitlab.internal.madrigal.ru" = {
      user         = "git";
      identityFile = "/run/secrets/ssh/gitlab-work";
    };

    "github.com" = {
      user         = "git";
      identityFile = "/run/secrets/ssh/github";
    };


  };
};
}
