{ pkgs, paths, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (paths.hardware + /amd-gpu.nix)

    (paths.desktop_environments + /kde_plasma/environment.nix)

    (paths.modules + /configuration.nix)
    (paths.modules + /memory.nix)
    (paths.modules + /aliases.nix)
    (paths.modules + /ssh-knownhosts.nix)
    (paths.modules + /printing.nix)
    (paths.modules + /cross-compilation.nix)

    (paths.profiles + /generic.nix)
    (paths.profiles + /development.nix)
    (paths.profiles + /gaming.nix)
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "quiet" "loglevel=3" ];
  boot.initrd.systemd.enable = true;
  boot.loader.timeout = 3;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "marcel-pc";

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # NixOS Rebuild Limits
  nix.settings = {
    max-jobs = 4;
    cores = 14;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Group Setup
  users.groups.secret-manager = { };

  # User Account Setup
  users.users.marcel = {
    isNormalUser = true;
    description = "Marcel";
    extraGroups = [
      "networkmanager"
      "secret-manager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Set up /etc/nixos/secrets/ directory permissions
  systemd.tmpfiles.rules = [
    "z /etc/nixos/secrets/** 0775 root secret-manager -"
  ];

  # DO NOT CHANGE STATE WITHOUT READING DOCS!
  system.stateVersion = "24.11";
}
