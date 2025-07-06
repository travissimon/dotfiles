{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../cachix/hyprland.nix
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Bootloader
  boot = {
    loader = {
      grub = {
        enable = true;
	device = "nodev";
        useOSProber = true;
	efiSupport = true;
      };
      efi = {
	canTouchEfiVariables = true;
	efiSysMountPoint = "/boot";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "moggio";
    networkmanager.enable = false;
    wireless.enable = true;
  };

  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
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

  services = {
    xserver.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    printing = {
      enable = true;
      drivers = [
        pkgs.hplipWithPlugin
      ];
    };

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

  };



  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tsimon = {
    isNormalUser = true;
    description = "Travis Simon";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # compression
    bzip2
    bzip3
    gzip
    unzip
    zip
    zstd

    # development
    git
    glib

    # internet
    firefox

    # libraries
    libnotify

    # cmdline
    bc
    curl
    file
    fzf
    gawk
    stow
    tree
    which
    wget

    # graphics
    gimp3-with-plugins
    inkscape-with-extensions
    imagemagick

    # monitoring
    mtr		# network diagnostic
    nmap	# port scanning
    btop	# top replacement
    iotop	# io monitoring
    iftop	# network monitoring
    gnome-system-monitor

    # system call monitoring
    strace   	  # system calls
    ltrace	  # library calls
    lsof	  # list open files

    # system tools
    lm_sensors		# for 'sensors' command
    ethtool
    pciutils		# lspci
    usbutils		# lsusb

    # terminals
    alacritty
    ghostty
    kitty


    # mutlimedia
    ffmpeg
    vlc

    # nonsense
    cowsay
    fastfetch

    # hyprland
    fuzzel
    hypridle
    slurp
    wallust
    wl-clipboard
    wlogout
    wofi
  ];

  # hyprland?
  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    waybar.enable = true;
    hyprlock.enable = true;
    nm-applet.indicator = true;
    dconf.enable = true;
  };


  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      font-awesome
      inter
      material-icons
      noto-fonts
      roboto
      roboto-mono
    ];
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
