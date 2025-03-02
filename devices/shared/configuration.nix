{ config, pkgs, agenix, ... }:

{
  imports =
    [
			./locale.nix
      ./networking.nix
			./sound.nix
			./mouse.nix
    ];

  # Sudo Setup
  security.sudo.extraConfig = ''
    Defaults    timestamp_timeout=30
    Defaults    passwd_tries=3
    Defaults    insults
  '';
}
