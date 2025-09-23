{ config, pkgs, agenix, ... }:

{
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

	# X11 Keyboard Config
	services.xserver.xkb = {
		layout = "pl";
		variant = "";
	};

	# General Keyboard Config
	console.keyMap = "pl2";

	# Group Setup
	users.groups.secret-manager = {};

	# User Account Setup
	users.users.marcel = {
		isNormalUser = true;
		description = "Marcel";
		extraGroups = [ "networkmanager" "secret-manager" "wheel" ];
		packages = with pkgs; [
		#	thunderbird
		];
	};

	# Set up /etc/nixos/secrets/ directory permissions
	systemd.tmpfiles.rules = [
		"z /etc/nixos/secrets/** 0775 root secret-manager -"
	];

	# Allow Unfree Packages
	nixpkgs.config.allowUnfree = true;

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;
}
