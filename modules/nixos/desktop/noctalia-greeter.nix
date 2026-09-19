{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.noctalia-greeter.nixosModules.default];

  programs.noctalia-greeter = {
    enable = true;
    greeter-args = "--session niri";
    passwordless-sync-users = ["andriano"];

    settings = {
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
        path = "${pkgs.bibata-cursors}/share/icons";
      };

      appearance = {
        hide_logo = true;
      };

      keyboard = {
        layout = "us,ru";
        variant = ",";
        options = "grp:alt_shift_toggle";
      };
    };
  };
}
