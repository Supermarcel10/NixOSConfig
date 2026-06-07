{ lib, pkgs, ... }:

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

      # Disable UART/Serial Console
      enable_uart = {
        enable = lib.mkDefault true;
        value = lib.mkForce 0;
      };

      # Disable auto-detection of cameras/DSI displays
      camera_auto_detect = {
        enable = lib.mkDefault true;
        value = lib.mkForce 0;
      };
      display_auto_detect = {
        enable = lib.mkDefault true;
        value = lib.mkForce 0;
      };

      # Disable HDMI (headless)
      "hdmi_ignore_hotplug:0" = {
        enable = lib.mkDefault true;
        value = lib.mkForce 1;
      };
      "hdmi_ignore_hotplug:1" = {
        enable = lib.mkDefault true;
        value = lib.mkForce 1;
      };
      "hdmi_ignore_cec:0" = {
        enable = lib.mkDefault true;
        value = lib.mkForce 1;
      };
      "hdmi_ignore_cec:1" = {
        enable = lib.mkDefault true;
        value = lib.mkForce 1;
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
        value = lib.mkDefault "on";
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

  # Error log level only
  boot.consoleLogLevel = lib.mkForce 3;

  boot.kernelParams = [
    "usbcore.autosuspend=20"
    "nvme_core.default_ps_max_latency_us=200"
    "pcie_aspm.policy=powersave"
  ];

  boot.blacklistedKernelModules = [
    "snd_bcm2835"
    "brcmfmac"
    "brcmutil"
    "bluetooth"
    "btbcm"
    "btintel"
    "btrtl"
    "btusb"
  ];

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
    MaxRetentionSec=1day
    Compress=yes
    RateLimitIntervalSec=30s
    RateLimitBurst=1000
  '';

  systemd.services.ethtool-end0-power = {
    description = "Apply end0 power-saving ethtool settings";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-networkd.service" ];
    bindsTo = [ "sys-subsystem-net-devices-end0.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.ethtool}/bin/ethtool -s end0 wol d
    '';
  };
}
