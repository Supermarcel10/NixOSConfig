{ config, lib, pkgs, ... }:

{
	services.xserver.videoDrivers = ["nvidia"];
	
	hardware.graphics = {
		enable = true;
	};
	
	hardware.nvidia = {
		modesetting.enable = true;
		powerManagement.enable = false;
		powerManagement.finegrained = false;
		open = false;
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
	};

	# Fix suspend black screen
	# https://discourse.nixos.org/t/black-screen-after-suspend-hibernate-with-nvidia/54341/21
	systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
}
