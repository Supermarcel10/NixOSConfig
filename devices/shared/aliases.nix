{ config, pkgs, ... }:

{
	environment.shellAliases = {
		# QR Code Generation
		qr = "qrencode -t ansiutf8";

		# Change Directory Aliases
		desktop = "cd ~/Desktop/";
		downloads = "cd ~/Downloads/";

		# NixOS Edit
    nrs = "sudo nixos-rebuild switch --flake ~/.nixos#$(hostname)";
	};
}
