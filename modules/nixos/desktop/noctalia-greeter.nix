{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.noctalia-greeter.nixosModules.default];

  programs.noctalia-greeter = {
    enable = true;
    greeter-args = "--session niri";

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

  # Used by Noctalia Shell when syncing its wallpaper and palette to the greeter.
  security.polkit.enable = true;
}
