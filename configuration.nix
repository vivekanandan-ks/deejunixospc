# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
  ];

  #if u are changing the config from root to rootless mode,
  #follow this: https://discourse.nixos.org/t/docker-rootless-containers-are-running-but-not-showing-in-docker-ps/47717
  #Enabling docker in rootless mode.
  #Don't forget to include the below commented commands to start the docker daemon service,
  #coz just enabling doesn't start the daemon
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
    #systemctl --user enable --now docker
    #systemctl --user start docker
    #systemctl --user status docker # to check the status


  #download buffer size; default size is 16mb (16*1024*1024)
  nix.settings.download-buffer-size = 67108864;

  # Bootloader.
  # systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #kde-connect
  programs.kdeconnect.enable = true;

  #Enable bluetooth
  hardware.bluetooth.enable = true;

  # enable Hyprland
  #programs.hyprland.enable = true;

  #Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  #enable flatpak
  services.flatpak.enable = true;

  #enable unfree services
  nixpkgs.config.allowUnfree = true;

  #enable fish shell
  programs.fish ={
    enable = true;
    shellAliases = {
      ksvcdtoflake = "cd ~/Documents/ksvnixospcconfigs/flakebasedconfigs/" ;
      ksvnixconfigbackup = ''mkdir "$(date +'%Y-%m-%d_%H-%M')_backup" && \
                            cp configuration.nix flake.lock flake.nix hardware-configuration.nix \
                            "$(date +'%Y-%m-%d_%H-%M')_backup/"'' ;
      ksvsavetogithub = ''eval (ssh-agent -c) && ssh-add ~/.ssh/ghnixospcconfig && git add .  && \
                          git commit && git push -u origin main'' ;
      ksvnixosproperfullupgrade-boot = ''ksvcdtoflake && ksvnixconfigbackup && \
                                        ksvsavetogithub && nh os boot -ua .'' ;
      ksvnixosproperfullupgrade-switch = ''ksvcdtoflake && ksvnixconfigbackup && \
                                          ksvsavetogithub && nh os switch -ua .'' ;
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.mutableUsers = false; 
  #this will make all user management only via nixos and imperative user creations or 
  #anything in kde or commands won't persist the nixos-rebuild command.

  users.users.root.hashedPassword = "$6$/Yo/IR.A6rGbFVr6$a6c7yhjPYGuJOBBkcPXl/SjZ531tEUHtkY3tX3np2dcX6JpZg.Myrwdnz.fhqci0Sg83vU8lDYmdpSAQqD.OF0" ;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ksvnixospc = {
    isNormalUser = true;
    description = "ksvnixospc";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPassword = "$6$DmrUUL7YWFMar6aA$sAoRlSbFH/GYETfXGTGa6GSTEsBEP1lQ6oRdXlQUsqhRB7OTI2vTmVlx64B2ihcez8B0q0l8/Vx1pO8c82bxm0" ;
    shell = pkgs.fish;
    packages = (with pkgs; [
      #stable
      kdePackages.kate
      python3

    ])

    ++

    (with pkgs-unstable;[
      #unstable
      obs-studio
      waveterm
      warp-terminal
      tor-browser

    ]);
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "ksvnixospc";

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (with pkgs; [
      #stable
      git
      vim
      nano
      wget

    ])

    ++

    (with pkgs-unstable;[
      #unstable
      git-town
      btop
      fish
      fastfetch
      bat
      vlc
      telegram-desktop
      devbox
      collector
      localsend
      spacedrive
      kitty
      android-tools
      google-chrome
      vscode
      tldr
      lsd
      rip2
      nh
      brave

    ]);

  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
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
  system.stateVersion = "24.11"; # Did you read the comment?

}
