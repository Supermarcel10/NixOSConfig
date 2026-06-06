{ options, lib, pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";

    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  services.resolved = {
    enable = true;
  }
  # TODO: Remove this conditional once nixos-raspberrypi updates to a NixOS
  # version where services.resolved.settings exists (26.05+). At that point,
  # the RPi nodes will also have this option and we can set it unconditionally.
  // lib.optionalAttrs (options.services.resolved ? settings) {
    settings = {
      Resolve = {
        DNSSEC = "true";
        DNSOverTLS = "yes";
      };
    };
  };

  networking.nameservers = [
    "2606:4700:4700::1111#cloudflare-dns.com" # Cloudflare (IPv6)
    "2606:4700:4700::1001#cloudflare-dns.com" # Cloudflare Backup (IPv6)
    "1.1.1.1#cloudflare-dns.com" # Cloudflare (IPv4)
    "1.0.0.1#cloudflare-dns.com" # Cloudflare Backup (IPv4)
  ];
}
