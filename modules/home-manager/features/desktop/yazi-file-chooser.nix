{
  config,
  pkgs,
  ...
}: let
  chooser = pkgs.writeShellScript "yazi-file-chooser" ''
    set -eu

    directory="$2"
    path="$4"
    selection="$5"

    if [ "$directory" = "1" ]; then
      cwd_selection="$selection.cwd"
      ${pkgs.alacritty}/bin/alacritty --title "Yazi File Chooser" -e \
        ${config.programs.yazi.finalPackage}/bin/yazi \
        --chooser-file="$selection" --cwd-file="$cwd_selection" "$path"

      if [ ! -s "$selection" ] && [ -s "$cwd_selection" ]; then
        ${pkgs.coreutils}/bin/cp -- "$cwd_selection" "$selection"
      fi
      ${pkgs.coreutils}/bin/rm -f -- "$cwd_selection"
    else
      ${pkgs.alacritty}/bin/alacritty --title "Yazi File Chooser" -e \
        ${config.programs.yazi.finalPackage}/bin/yazi \
        --chooser-file="$selection" "$path"
    fi
  '';
in {
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${chooser}
    default_dir=$HOME
    open_mode=suggested
    save_mode=suggested
  '';

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];
    config = {
      niri = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.FileChooser" = ["termfilechooser" "gtk"];
      };
      common.default = ["gtk"];
    };
  };
}
