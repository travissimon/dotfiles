{ config, lib, pkgs, ... }:

{
  nixpkgs = {
    config.allowUnfree = true;
  };

  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "nvidia-drm.fbdev=1" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "i2c-dev" "i2c-piix4" "v4l2loopback" "snd-aloop" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';
  };

  security.polkit.enable = true;

  networking.hostName = "moggio";
  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Sydney";

  i18n = {
    defaultLocale = "en_AU.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-120n.psf.gz";
    keyMap = "us";
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "root" "tsimon" ];
      auto-optimise-store = true;
      substituters = [
        "https://hyprland.cachix.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
  };

  hardware = {
    sane = {
      enable = true;
      extraBackends = [ pkgs.hplipWithPlugin ];
    };
  };

  services = {
    xserver.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    udev.packages = [
      pkgs.openrgb-with-all-plugins
    ];

    hardware = {
      openrgb.enable = true;
    };

    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    avahi = {               # scan for printers
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };

    dbus = {
      enable = true;
      implementation = "broker";
    };

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    emacs = {
      enable = true;
      package = pkgs.emacs-gtk;
    };

    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };

    open-webui = {
      enable = true;
      port = 8888;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

  };

  users.users = {
    tsimon = {
      isNormalUser = true;
      description = "Travis Simon";
      extraGroups = [ "wheel" "audio" "scanner" "lp" "docker" ];
    };
  };

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    hyprlock.enable = true;

    firefox.enable = true;

    obs-studio = {
      enableVirtualCamera = true;
    };

    steam = {
      enable = true;
    };

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        fontconfig
        wayland
        libGL
        alsa-lib
        vulkan-loader
        libpulseaudio
        speechd-minimal
        udev
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      alacritty
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      bc
      btop-cuda
      brotli
      bzip2
      chromedriver
      coreutils-full
      cpio
      curl
      devenv
      diffutils
      ffmpeg
      findutils
      file
      gawk
      gcc
      ghostscript
      ghostty
      gnome-system-monitor
      gnugrep
      gnumake
      gnused
      gnupg
      gnutar
      go
      godot
      google-chrome
      gzip
      hyprshot
      hplipWithPlugin
      inotify-tools
      iotop
      iftop
      kitty
      kvmtool
      less
      libjpeg
      libpng
      libreoffice
      llama-cpp
      lm_sensors
      ltrace
      lsof
      naps2
      ncurses
      nmap
      netcat
      nix-output-monitor
      openrgb-with-all-plugins
      pciutils
      pgadmin4-desktopmode
      qemu
      ripgrep
      rsync
      sane-frontends
      sane-backends
      su
      stow
      strace
      sysstat
      time
      tree
      usbutils
      vlc
      virt-manager
      wget
      which
      xsane
      zstd
      xz
    ];
  };

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      font-awesome
      inter
      lato
      material-icons
      noto-fonts
      roboto
      nerd-fonts.roboto-mono
    ];
  };

  virtualisation.docker.enable = true;

  system.stateVersion = "25.05";

}

