# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

let
  unstable = import (builtins.fetchTarball{
    url = "https://github.com/NixOS/nixpkgs/tarball/c75037bbf9093a2acb617804ee46320d6d1fea5a";
    sha256 = "1hs4rfylv0f1sbyhs1hf4f7jsq4np498fbcs5xjlmrkwhx4lpgmc";
  }) { 
        config = {
          allowUnfree = true;
          permittedInsecurePackages = ["electron-25.9.0"]; #Needed since obsidian lags behind in EOL electron releases
        };
      };
in 
{ config, pkgs, ... }:

{
  imports = [ 
      /etc/nixos/hardware-configuration.nix # Include the results of the hardware scan.
      <home-manager/nixos>
  ];

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "2";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;

  networking.hostName = "XPS-9530"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
 
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # logind
  services.logind = {
    lidSwitchExternalPower = "suspend";
    lidSwitch = "suspend-then-hibernate";
  };

  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  fonts.fontconfig.defaultFonts.monospace = [
    "Comic Code"
  ];

  # Enable networking
  networking.networkmanager.enable = true;

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

  # X11
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager = {
    defaultSession = "gnome";
    gdm = {
      enable = true;
      wayland = false;
    };
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.unei = {
    isNormalUser = true;
    description = "unei";
    extraGroups = [ "networkmanager" "wheel" "dialout" "docker"];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # home manager config
  home-manager.useUserPackages = true; # recommended in the manual
  home-manager.useGlobalPkgs = true; # saves time and adds consistency
  home-manager.users.unei = import ./home.nix;
  environment.pathsToLink = [ "/share/zsh" ]; # recommended
 
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Programs (which need .desktop entries)
    firefox
    chromium 
    unstable.obsidian
    qemu
    prusa-slicer
    freecad
    libsForQt5.okular
    keepass
    protonvpn-gui
    discord
    prismlauncher
    xournalpp

    # Desktop stuffs
    gnomeExtensions.clipboard-indicator 

    # wine stuff (mainly for lutris)
    # wine
    # wineWowPackages.stable
    wineWowPackages.unstableFull
    winetricks

    # Gaming
    lutris 

    # System stuffs
    powertop

    # still needed for nix-shell setup for jobarena
    docker-compose

    # Allianz AVC
    citrix_workspace
  ];

  # environment.variables = {
  #   EDITOR = "hx";
  # };

  # nixOS specific Shell aliases
  environment.shellAliases = {
    nixconf = "cd /etc/nixos && sudo -E hx /etc/nixos/configuration.nix"; # -E needed to keep clipboard intact
    nixrebuild = "sudo nixos-rebuild switch";
    ns = "nix-shell --run zsh";
    igrep = "grep -i";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  powerManagement.powertop.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services.syncthing = {
    enable = true;
    user = "unei";
    dataDir = "/home/unei/syncthing";
    overrideFolders = false;
    overrideDevices = false;
  };

  # Postgresql stuff
  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "unei";
        ensureClauses = {
          login = true;
          createdb = true;
        };
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };

#  services.pgadmin = {
#    enable = true; 
#    initialEmail = "mattis.sievers@pm.me";
#    initialPasswordFile = "/home/unei/.pgadmin_pw";
#  };

  # VIRTUALIZATION
  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      
    };
  }; 

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

#  # Load nvidia driver for Xorg and Wayland
#  services.xserver.videoDrivers = ["nvidia"];
#  hardware.nvidia = {
#
#    # Modesetting is required.
#    modesetting.enable = true;
#
#    # Enable power management (do not disable this unless you have a reason to).
#    # Likely to cause problems on laptops and with screen tearing if disabled.
#    powerManagement = {
#      enable = true;
#      finegrained = true;
#    };
#
#    # Use the NVidia open source kernel module (not to be confused with the
#    # independent third-party "nouveau" open source driver).
#    # Support is limited to the Turing and later architectures. Full list of 
#    # supported GPUs is at: 
#    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
#    # Only available from driver 515.43.04+
#    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
#    # open = true; # the graphics card on my XPS-9350 seems not to be compatible with the open source kernel as of 08.09.2023
#
#    # Enable the Nvidia settings menu,
#    # accessible via `nvidia-settings`.
#    # nvidiaSettings = true;
#
#    # Optionally, you may need to select the appropriate driver version for your specific GPU.
#    package = config.boot.kernelPackages.nvidiaPackages.stable;
#
#    prime = {
#      #sync.enable = true;
#      offload = {
#        enable = true;
#        enableOffloadCmd = true;
#      };
#
#      # Make sure to use the correct Bus ID values for your system!
#      intelBusId = "PCI:0:2:0";
#      nvidiaBusId = "PCI:1:0:0";
#    };
#  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
}
