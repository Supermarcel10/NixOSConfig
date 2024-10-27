{ config, pkgs, ... }:

{
  environment.shellAliases = {
    # Vim Aliases
    nano = "nvim";
    emacs = "nvim";
    vim = "nvim";
    vi = "nvim";

    # Change Directory Aliases
    nixos = "cd /etc/nixos/";
    desktop = "cd ~/Desktop/";
    downloads = "cd ~/Downloads/";

    # NixOS Edit
    nixos-cfg = "cd /etc/nixos/ && nvim configuration.nix";
  };
}