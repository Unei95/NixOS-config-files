# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

let
  unstable = import (builtins.fetchTarball{
    url = "https://github.com/NixOS/nixpkgs/tarball/15f4ee454b1dce334612fa6843b3e05cf546efab";
    sha256 = "17pr9kf46019gf9nkg7jsa0h81adwbkdjwlk0i57nycnhad3vph1";
  })
  { 
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "libsoup-2.74.3"
      ];
    };
  };

  hosts = import ./hosts.nix ;
  # openwebui = import ./open_webui.nix { inherit hosts; };
in 
{ lib, config, pkgs, ... }:

{
  imports = [ 
    /etc/nixos/hardware-configuration.nix # Include the results of the hardware scan.
    ./graphics_tablet.nix
    <home-manager/nixos>
  ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        # needed because of high resolution display
        consoleMode = "2";
      };
      efi.canTouchEfiVariables = true;
    };

    initrd.kernelModules = [ "pinctrl_tigerlake" ];
    tmp.cleanOnBoot = true;

    binfmt.emulatedSystems = [
        "aarch64-linux"
    ];
  };

  # compatability for framework12
  # Fix TRRS headphones missing a mic
  # https://github.com/torvalds/linux/commit/7b509910b3ad6d7aacead24c8744de10daf8715d
  boot.extraModprobeConfig = lib.mkIf (lib.versionOlder config.boot.kernelPackages.kernel.version "6.13.0") ''
    options snd-hda-intel model=dell-headset-multi
  '';

  # Needed for desktop environments to detect display orientation
  hardware.sensor.iio.enable = lib.mkDefault true;

  # Everything is updateable through fwupd
  services.fwupd.enable = true;

  networking = {
    hostName = hosts.hostName; # Define your hostname.
    networkmanager.enable = true;

    interfaces.${hosts.interface} = {
      ipv4.addresses = [{
      address = hosts.staticIp;
      prefixLength = 24;
    }];
    };
  };

  hardware.bluetooth.enable = true;

  fonts.fontconfig.defaultFonts.monospace = [
    "Comic Code"
  ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # somehow nsncd was not enabled
  services.nscd.enableNsncd = true;

  programs.ssh.startAgent = true;

  services.input-remapper.enable = true;

  # X11
  services.xserver.enable = true;


 services.displayManager.sddm.enable = true;
 services.desktopManager.plasma6.enable = true;

  # services.xserver.desktopManager.gnome.enable = true;
  # services.displayManager.defaultSession = "plasmax11";
  # services.xserver.displayManager = {
  #   gdm = {
  #     enable = true;
  #   };
  # };
  programs.xwayland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };
  # Configure console keymap
  console.keyMap = "us-acentos";
  console.font = "Comic Code";

  services.flatpak.enable = true;
  
  security = {
    rtkit.enable = true;
  };

  # Enable sound with pipewire.
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


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.unei = {
    isNormalUser = true;
    description = "unei";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # Docker
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "unei" ];

  # home manager config
  home-manager.useUserPackages = true; # recommended in the manual
  home-manager.useGlobalPkgs = true; # saves time and adds consistency
  home-manager.users.unei = import ./home.nix {inherit pkgs unstable;};
  environment.pathsToLink = [ "/share/zsh" ]; # recommended
 
  # Allow unfree packages
  nixpkgs.config = { allowUnfree = true; };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Programs (which need .desktop entries)
    # unstable.vivaldi
    chromium 
    obsidian
    kdePackages.okular
    discord
    xournalpp
    signal-desktop
    calibre
    slack
    dbeaver-bin
    gimp
    vial
    libreoffice
    protonvpn-gui
    proton-pass
    unetbootin

    # LSPs
    bash-language-server

    # programming/cli stuff not configurable via homemanager(yet, hopefully)
    # unstable.github-copilot-cli

    # Desktop stuffs
    google-cursor
    xorg.libXrender
    # maliit-keyboard # on-screen keyboard when running a wayland session
    
    # wine stuff (mainly for lutris)
    wine
    wineWowPackages.full
    winetricks

    # Gaming
    lutris

    # System stuffs
    powertop
    unzip
    toybox
  ];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';

  environment.shellAliases = {
    nixconf = "hx /home/unei/projects/nixos-config-files"; # -E needed to keep clipboard intact
    nixrebuild = "sudo nixos-rebuild switch";
    ns = "nix-shell --run zsh";
    igrep = "grep -i";
  };

  powerManagement.powertop.enable = true;

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "smort.cute";
        system = "aarch64-linux";
        sshUser = "unei";
        sshKey = "/root/.ssh/remotebuild";
        supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
      }
    ];

    settings.builders-use-substitutes = true;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true; 
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
}
