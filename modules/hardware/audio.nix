{ ... }:

{
  # Disable power saving on HDA to prevent crackling/latency
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  # Focusrite Scarlett 2i2 Gen 4
  services.udev.extraRules = ''
    ATTR{idVendor}=="1235", ATTR{idProduct}=="8219", ATTR{power/control}="on"
  '';
}
