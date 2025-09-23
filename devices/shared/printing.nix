{ config, pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = with pkgs; [ cups-filters cups-browsed ];
  };

  services.avahi = {
    enable = true;
    nssmdns = true; # Changed from nssmdns4
    openFirewall = true;
  };
}
