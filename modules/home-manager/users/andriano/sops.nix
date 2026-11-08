{
  config,
  pkgs,
  repoRoot,
  ...
}: {
  home.packages = with pkgs; [age sops];
  sops = {
    defaultSopsFile = "${repoRoot}/secrets/users/andriano.yaml";
    age = {
      keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      generateKey = true;
    };
    # Plain file so tools can read it directly (pi mcp.json uses `!cat`).
    secrets."context7-api-key" = {};
  };
}
