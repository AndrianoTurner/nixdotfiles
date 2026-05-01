{config,...}:{
 sops = {
  defaultSopsFile = ../secrets.yaml;

    secrets = {
      "ssh/gitea-host"    = {};
      "ssh/proxmox-host"  = {};
      "ssh/madrigal-host" = {};

      "ssh/gitea"         = { mode = "0400"; owner = "andriano"; };
      "ssh/proxmox"       = { mode = "0400"; owner = "andriano"; };
      "ssh/gitlab"        = { mode = "0400"; owner = "andriano"; };
      "ssh/github"        = { mode = "0400"; owner = "andriano"; };
      "ssh/github-lesha"  = { mode = "0400"; owner = "andriano"; };
      "ssh/gitlab-work"   = { mode = "0400"; owner = "andriano"; };
      "ssh/mdrg-servers"  = { mode = "0400"; owner = "andriano"; };
    };

  };
}
