{ config, pkgs, agenix, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia-setup.nix
      ./development.nix
      ./sound.nix
      ./aliases.nix
      ./secrets/secrets.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-1ede3cde-aee5-4e17-9126-a3efadc6b719".device = "/dev/disk/by-uuid/1ede3cde-aee5-4e17-9126-a3efadc6b719";
  boot.supportedFilesystems = [ "ntfs" ];
  networking.hostName = "marcel-pc";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/run/media/marcel/win_os" = {
    device = "/dev/disk/by-uuid/2A40A6FA40A6CC3F";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=0022"
      "noauto"
      "x-systemd.automount"
    ];
  };

  # Networking
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Time Zone
  time.timeZone = "Europe/London";

  # Internationalization Settings
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # X11 Windowing System
  services.xserver.enable = true;

  # KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Override KDE Plasma packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    spectacle
  ];

  # X11 Keyboard Config
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # General Keyboard Config
  console.keyMap = "pl2";

  # Printing CUPS Service
  services.printing.enable = true;

  # Sudo Setup
  security.sudo.extraConfig = ''
    Defaults	timestamp_timeout=30
    Defaults	passwd_tries=3
    Defaults	insults
  '';

  # Group Setup
  users.groups.secret-manager = {};

  # User Account Setup
  users.users.marcel = {
    isNormalUser = true;
    description = "Marcel";
    extraGroups = [ "networkmanager" "secret-manager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Set up /etc/nixos/secrets/ directory permissions
  systemd.tmpfiles.rules = [
    "z /etc/nixos/secrets/** 0775 root secret-manager -"
  ];

  # Allow Unfree Packages
  nixpkgs.config.allowUnfree = true;

  # Install Programs
  # BASICS
  programs.firefox.enable = true;

  # GAMES
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    # BASICS
    unixtools.whereis
    fastfetch
    neovim
    killall
    niv
    age
    agenix.packages.${system}.default
    qrencode
    flameshot
    onlyoffice-bin_latest
    wget
    btop
    tree
    lm_sensors
    fanctl

    # GENERAL APPS
    obsidian
    vesktop # Discord without broken screenshare
    teams-for-linux
    zoom-us
    ferdium
    tidal-hifi
    filezilla
    vlc

    # GAMES
    prismlauncher
    the-powder-toy

    # TEMP
    chromium
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Firewall
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
