{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
			./../shared/hardware/amd-gpu.nix

      # TODO: Find a neater way to have neater shared configs
      ./../shared/configuration.nix
      ./../shared/aliases.nix
			./../shared/desktop_environments/kde_plasma/environment.nix
			./../shared/printing.nix

      # TODO: Find a neater way to have app profiles
      ./../../profiles/generic.nix
      ./../../profiles/development.nix
			./../../profiles/gaming.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "marcel-pc";

	boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

	# Group Setup
  users.groups.secret-manager = {};

  # User Account Setup
  users.users.marcel = {
    isNormalUser = true;
    description = "Marcel";
    extraGroups = [ "networkmanager" "secret-manager" "wheel" ];
    packages = with pkgs; [
			kdePackages.kate
    #  thunderbird
    ];
  };

  # Set up /etc/nixos/secrets/ directory permissions
  systemd.tmpfiles.rules = [
    "z /etc/nixos/secrets/** 0775 root secret-manager -"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

	# DO NOT CHANGE STATE WITHOUT READING DOCS!
  system.stateVersion = "24.11";
}
