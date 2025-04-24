{ config, pkgs, ... }:

{
	networking.networkmanager.enable = true;
	networking.nameservers = [
		"1.1.1.1" # Cloudflare (IPv4)
		"2606:4700:4700::1111"	# Cloudflare (IPv6)
		"1.0.0.1" # Cloudflare Backup (IPv4)
		"2606:4700:4700::1001" # Cloudflare Backup (IPv6)
	];

	# networking.wireless.enable = true;

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Firewall
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
}
