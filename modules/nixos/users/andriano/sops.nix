{inputs, ...}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    defaultSopsFile = ../../../../secrets/system/shared.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}
