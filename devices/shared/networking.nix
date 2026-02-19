{ pkgs, ... }:

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
    dnssec = "true";
    extraConfig = ''
      			DNSOverTLS=yes
      			'';
  };

  networking.nameservers = [
    "2606:4700:4700::1111#cloudflare-dns.com" # Cloudflare (IPv6)
    "2606:4700:4700::1001#cloudflare-dns.com" # Cloudflare Backup (IPv6)
    "1.1.1.1#cloudflare-dns.com" # Cloudflare (IPv4)
    "1.0.0.1#cloudflare-dns.com" # Cloudflare Backup (IPv4)
  ];

  # networking.wireless.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Firewall
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}
