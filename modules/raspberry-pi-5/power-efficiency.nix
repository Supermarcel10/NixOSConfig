{ lib, ... }:

{
  # FIRMWARE (config.txt)
  hardware.raspberry-pi.config.all = {
    options = {
      arm_boost = {
        enable = lib.mkDefault true;
        value = lib.mkForce 0; # Disable overclock boost
      };
      gpu_mem = {
        enable = lib.mkDefault true;
        value = lib.mkDefault 16; # Minimum GPU memory (headless)
      };
    };

    base-dt-params = {
      # Disable audio
      audio = {
        enable = lib.mkDefault true;
        value = lib.mkForce "off";
      };

      # Disable ACT LEDs
      act_led_trigger = {
        enable = lib.mkDefault true;
        value = lib.mkDefault "none";
      };
      act_led_activelow = {
        enable = lib.mkDefault true;
        value = lib.mkDefault "off";
      };

      # Disable PWR LEDs
      pwr_led_trigger = {
        enable = lib.mkDefault true;
        value = lib.mkDefault "none";
      };
      pwr_led_activelow = {
        enable = lib.mkDefault true;
        value = lib.mkDefault "off";
      };

      # Disable Ethernet PHY LEDs
      eth_led0 = {
        enable = lib.mkDefault true;
        value = lib.mkDefault "4";
      };
      eth_led1 = {
        enable = lib.mkDefault true;
        value = lib.mkDefault "4";
      };
    };

    dt-overlays = {
      # Disable display/GPU driver (headless)
      vc4-kms-v3d = {
        enable = lib.mkForce false;
      };

      # Disable Bluetooth radio
      "disable-bt" = {
        enable = lib.mkDefault true;
      };

      # Disable WiFi radio
      "disable-wifi" = {
        enable = lib.mkDefault true;
      };
    };
  };

  # POWER MANAGEMENT
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
  powerManagement.powertop.enable = true;

  boot.kernelParams = [
    "usbcore.autosuspend=20"
  ];
}
