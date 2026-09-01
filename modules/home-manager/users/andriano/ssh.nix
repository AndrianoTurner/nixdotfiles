{config, ...}: {
  programs.ssh.settings = {
    "gitlab.internal.madrigal.ru" = {
      user = "git";
      identityFile = config.sops.secrets."ssh/gitlab-work".path;
      identitiesOnly = "yes";
    };

    "github.com" = {
      user = "git";
      identityFile = config.sops.secrets."ssh/github".path;
      identitiesOnly = "yes";
    };
  };

  sops.secrets = {
    "ssh/gitlab-work".mode = "0400";
    "ssh/github".mode = "0400";
  };
}
