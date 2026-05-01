{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.lazyvim.homeManagerModules.default];
  programs.lazyvim = {
    enable = true;
    extras = {
      lang.nix.enable = true;
      lang.rust.enable = true;
    };

    # Additional packages (optional)
    extraPackages = with pkgs; [
      nixd # Nix LSP
      alejandra # Nix formatter
    ];

    # Only needed for languages not covered by LazyVim extras
    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      wgsl # WebGPU Shading Language
      templ # Go templ files
    ];
  };
}
