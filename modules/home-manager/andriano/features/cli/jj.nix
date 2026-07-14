{...}: {
  programs.jujutsu = {
    enable = true;

    settings = {
      user = {
        name = "AndrianoTurner";
        email = "danya.shibaev@gmail.com";
      };

      ui = {
        paginate = "never";
      };

      "--scope" = {
        "--when".repositories = ["~/work"];
        "--scope".user = {
          name = "Даниил Шибаев";
          email = "d.shibaev@madrigal.expert";
        };
      };
    };
  };
}
