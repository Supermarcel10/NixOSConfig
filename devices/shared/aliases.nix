{ config, pkgs, ... }:

{
	environment.shellAliases = {
		# Vim Aliases
		nano = "nvim";
		emacs = "nvim";
		vim = "nvim";
		vi = "nvim";

		# QR Code Generation
		qr = "qrencode -t ansiutf8";

		# Change Directory Aliases
		nixos = "cd /etc/nixos/";
		desktop = "cd ~/Desktop/";
		downloads = "cd ~/Downloads/";

		# NixOS Edit
		nixos-cfg = "cd /etc/nixos/ && nvim configuration.nix";
	};
}
