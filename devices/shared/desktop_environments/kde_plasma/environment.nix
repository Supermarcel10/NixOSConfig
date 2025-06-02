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
		konsole
	];

	programs.ssh.askPassword = "";

	environment.sessionVariables = {
		KDE_WALLET_SERVICE = "";
		KDE_WALLETD_AUTOSTART = "false";
	};

	# TODO: Copy over theme dotfile
}
