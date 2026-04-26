{pkgs,inputs, ...}: {
  imports = [

inputs.nixvim.homeModules.nixvim
    ./global
    ./features/cli
    ./features/desktop
  ];

}

