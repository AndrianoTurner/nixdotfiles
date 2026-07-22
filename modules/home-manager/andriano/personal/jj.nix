{
  programs.jujutsu.settings = {
    user = {
      name = "AndrianoTurner";
      email = "danya.shibaev@gmail.com";
    };

    "--scope" = {
      "--when".repositories = ["~/work"];
      "--scope".user = {
        name = "Даниил Шибаев";
        email = "d.shibaev@madrigal.expert";
      };
    };
  };
}
