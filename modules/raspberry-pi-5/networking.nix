{ options, lib, ... }:

{
  networking.useNetworkd = true;
  networking.networkmanager.enable = lib.mkForce false;

  services.resolved = {
    enable = true;
  }
  // lib.optionalAttrs (options.services.resolved ? settings) {
    settings = {
      Resolve = {
        DNSSEC = "true";
        DNSOverTLS = "yes";
      };
    };
  };

  networking.nameservers = [
    "2606:4700:4700::1111#cloudflare-dns.com"
    "2606:4700:4700::1001#cloudflare-dns.com"
    "1.1.1.1#cloudflare-dns.com"
    "1.0.0.1#cloudflare-dns.com"
  ];
}
