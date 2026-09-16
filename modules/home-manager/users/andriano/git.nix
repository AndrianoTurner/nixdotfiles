let
  workIdentity = {
    user = {
      name = "Даниил Шибаев";
      email = "d.shibaev@madrigal.expert";
    };
  };

  workRemoteConditions = [
    "hasconfig:remote.*.url:git@gitlab.internal.madrigal.ru:*/**"
    "hasconfig:remote.*.url:gitlab.internal.madrigal.ru:*/**"
    "hasconfig:remote.*.url:ssh://git@gitlab.internal.madrigal.ru/**"
    "hasconfig:remote.*.url:ssh://gitlab.internal.madrigal.ru/**"
    "hasconfig:remote.*.url:https://gitlab.internal.madrigal.ru/**"
  ];
in {
  programs.git = {
    settings = {
      user.name = "AndrianoTurner";
      user.email = "danya.shibaev@gmail.com";
    };

    includes =
      map (condition: {
        inherit condition;
        contents = workIdentity;
      })
      workRemoteConditions;
  };
}
