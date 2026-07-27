{...}: {
  programs.jujutsu = {
    enable = true;

    settings = {
      ui = {
        paginate = "never";
      };
    };
  };
}
