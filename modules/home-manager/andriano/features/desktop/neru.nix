{inputs, ...}: {
  imports = [
    inputs.neru.homeManagerModules.default
  ];

  services.neru = {
    enable = true;
    config = ''
      [hotkeys]
      "Ctrl+Alt+Space" = "hints"
      "Ctrl+Alt+G" = "grid"
      "Ctrl+Alt+C" = "recursive_grid"
      "Ctrl+Alt+S" = "scroll"
    '';
  };
}
