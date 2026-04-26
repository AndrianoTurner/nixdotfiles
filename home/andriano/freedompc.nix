{pkgs,inputs, ...}: {
  imports = [

     inputs.nixvim.homeManagerModules.nixvim
    ./global
    ./features/cli
    ./features/desktop
  ];

}

