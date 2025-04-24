{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
			./../shared/hardware/nvidia-gpu.nix

      # TODO: Find a neater way to have neater shared configs
      ./../shared/configuration.nix
			./../shared/desktop_environments/kde_plasma/environment.nix

      # TODO: Find a neater way to have app profiles
      ./../../profiles/generic.nix
      ./../../profiles/development.nix
			./../../profiles/gaming.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

	boot.initrd.luks.devices."luks-1ede3cde-aee5-4e17-9126-a3efadc6b719".device = "/dev/disk/by-uuid/1ede3cde-aee5-4e17-9126-a3efadc6b719";
  boot.supportedFilesystems = [ "ntfs" ];
  networking.hostName = "marcel-pc";

	boot.kernelPackages = pkgs.linuxPackages_zen;

	# Mount NTFS drive
	fileSystems."/run/media/marcel/win_os" = {
    device = "/dev/disk/by-uuid/2A40A6FA40A6CC3F";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "user=marcel"
      "group=users"
      "umask=0022"
      "noauto"
      "x-systemd.automount"
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
