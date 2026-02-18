{ config, lib, pkgs, ... }:

{
	boot.initrd.kernelModules = ["amdgpu"];
	boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
		"amdgpu.gpu_recovery=1"
  ];
	services.xserver.videoDrivers = ["amdgpu"];

  hardware.amdgpu.overdrive.enable = true;
	hardware.graphics = {
		enable = true;
		enable32Bit = true;
	};
}
