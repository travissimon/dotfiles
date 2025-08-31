{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {

  imports = [
    ./tsimon-modules
  ];

  home = {
    username = "tsimon";
    homeDirectory = "/home/tsimon";

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    packages = with pkgs; [
      angular-language-server
      bat
      bluez
      bluez-tools
      brightnessctl
      cava
      colorz
      cowsay
      code-cursor-fhs
      dconf
      easyeffects
      eza
      fastfetch
      fortune
      fuzzel
      fzf
      gvfs
      grim
      grimblast
      gtksourceview3
      helvum
      jq
      kubectl
      libgtop
      libsoup_3
      lsd
      nodePackages.nodejs
      nvd
      ollama-cuda
      # python3
      # python313Packages.cython
      # python313Packages.gpustat
      # python313Packages.modern-colorthief
      pywal16
      postman
      slurp
      shotcut
      steam
      swww
      typescript
      typescript-language-server
      wallust
      waypaper
      wakatime-cli
      wireplumber
      wl-clipboard
      wlogout
      wf-recorder
      wofi

      gimp3-with-plugins
      inkscape-with-extensions
      imagemagick
    ];

  };


  # Installation version
  home.stateVersion = "25.05";
}
