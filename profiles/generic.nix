{ config, pkgs, agenix, unstable, ... }:

{
	imports = [
		./../apps/kitty.nix
		./../apps/firefox.nix
		./../apps/via.nix
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
		agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
		qrencode
		flameshot
		onlyoffice-desktopeditors
		wget
		btop-rocm
		tree
		lm_sensors
		fanctl
		ripgrep
		unstable.lact

		# GENERAL APPS
		obsidian
		grayjay
		obs-studio
		(pkgs.blender.override {
      cudaSupport = true;
      inherit (pkgs) cudaPackages;
    })
		legcord # Discord replacement
		teams-for-linux
		zoom-us
		ferdium
		tidal-hifi
		filezilla
		mpv
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
