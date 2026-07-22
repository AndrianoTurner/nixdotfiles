{
  programs.git = {
    settings = {
      user.name = "AndrianoTurner";
      user.email = "danya.shibaev@gmail.com";
    };

    includes = [
      {
        condition = "gitdir:~/work/**/";
        contents.user = {
          name = "Даниил Шибаев";
          email = "d.shibaev@madrigal.expert";
        };
      }
      {
        condition = "gitdir:~/personal/**/";
        contents.user = {
          name = "AndrianoTurner";
          email = "danya.shibaev@gmail.com";
        };
      }
    ];
  };
}
