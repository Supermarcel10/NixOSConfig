{ lib, ... }:

{
  boot.kernelParams = [
    "quiet"
    "8250.nr_uarts=0"
  ];
  boot.consoleLogLevel = 3;
  boot.initrd.systemd.enable = true;
  boot.loader.timeout = 1;

  # Disable NetworkManager-wait-online block
  systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];

  # Desktop has no RF kill switch; rfkill save/restore just waits on
  # MediaTek BT /dev/rfkill. Leave kernel rfkill functional, skip state file.
  systemd.services.systemd-rfkill.enable = false;
  systemd.sockets.systemd-rfkill.enable = false;
}
