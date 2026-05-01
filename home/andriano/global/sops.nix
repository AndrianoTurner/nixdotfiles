{config,...}:{
 sops = {
  defaultSopsFile = ../secrets.yaml;
  age.sshKeyPaths = [ "/home/andriano/.ssh/andriano" ];

    secrets = {

      "ssh/gitea"        = { mode = "0400"; };
      "ssh/proxmox"      = { mode = "0400"; };
      "ssh/github"       = { mode = "0400"; };
      "ssh/gitlab-work"  = { mode = "0400"; };
    };
  };
}
