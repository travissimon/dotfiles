{
  pkgs,
  config,
  ...
}: {

  programs = {

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

  };

}
