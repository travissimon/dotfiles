{
  pkgs,
  config,
  ...
}: {

  programs = {

    git = {
      enable = true;
      userName = "tsimon";
      userEmail = "tsimon@gmail.com";
    };

  };

}
