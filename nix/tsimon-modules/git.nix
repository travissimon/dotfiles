{
  pkgs,
  config,
  ...
}: {

  programs = {

    git = {
      enable = true;
      settings.user.name = "tsimon";
      settings.user.email = "tsimon@gmail.com";
    };

  };

}
