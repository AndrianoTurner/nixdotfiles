{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [age sops];
  sops = {
    defaultSopsFile = ../../../../secrets/users/andriano.yaml;
    age = {
      keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      generateKey = true;
    };
  };
}
