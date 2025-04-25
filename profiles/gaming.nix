{ config, pkgs, ... }:

{
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true;
		dedicatedServer.openFirewall = true;
		localNetworkGameTransfers.openFirewall = true;
	};

	environment.systemPackages = with pkgs; [
		(lutris.override {
			extraPkgs = pkgs: [
				gamescope
				gamemode
				mangohud
      ];
    })
		prismlauncher
		the-powder-toy
	];
}
