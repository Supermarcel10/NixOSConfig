{ config, pkgs, agenix, unstable, ... }:

let
        lock-false = {
                Value = false;
                Status = "locked";
        };
        lock-true = {
                Value = true;
                Status = "locked";
        };
in
{
	imports = [
		./../apps/kitty.nix
		./../apps/firefox.nix
	];
  # TODO: Separate browser and create configurations
        # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
	nixpkgs.config.allowUnfree = true;
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
		ripgrep
		unstable.lact

		# GENERAL APPS
		obsidian
		obs-studio
		(pkgs.blender.override {
      cudaSupport = true;
      inherit (pkgs) cudaPackages;
    })
		vesktop # Discord without broken screenshare
		teams-for-linux
		zoom-us
		ferdium
		tidal-hifi
		filezilla
		vlc
		texliveFull
		inkscape
	];

	systemd.services.lact = {
	   description = "AMDGPU Control Daemon";
	   after = ["multi-user.target"];
	   wantedBy = ["multi-user.target"];
	   serviceConfig = {
	     ExecStart = "${unstable.lact}/bin/lact daemon";
	   };
	   enable = true;
	 };
}
