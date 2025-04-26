{ config, pkgs, ... }:

{
	# X11 Windowing System
	services.xserver.enable = true;

	# KDE Plasma Desktop Environment
	services.displayManager.sddm.enable = true;
	services.desktopManager.plasma6.enable = true;

	# Override KDE Plasma packages
	environment.plasma6.excludePackages = with pkgs.kdePackages; [
		spectacle
		kwalletmanager
		kwrited
	];

	# TODO: Copy over theme dotfile

}
