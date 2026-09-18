{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Default policy for every host without its own block. Without this, ssh
    # offers all ~7 keys loaded in the agent one by one and the server hits
    # MaxAuthTries ("Too many authentication failures") before we ever reach
    # the password prompt. IdentitiesOnly limits the offer to the identity
    # configured here; hosts that need an agent key declare it themselves.
    settings."*" = {
      identitiesOnly = "yes";
      identityFile = "~/.ssh/id_ed25519";
    };
  };
}
