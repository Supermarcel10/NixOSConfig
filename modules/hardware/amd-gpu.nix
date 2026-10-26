{ pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xfffd3fff"
    "amdgpu.gpu_recovery=1"
  ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.amdgpu.opencl.enable = true;
  hardware.amdgpu.overdrive.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = [ pkgs.lact ];

  systemd.services.lact = {
    description = "AMDGPU Control Daemon";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    enable = true;
  };
}
