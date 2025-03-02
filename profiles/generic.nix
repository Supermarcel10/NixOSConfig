{ config, pkgs, agenix, ... }:

{
  # TODO: Separate browser and create configurations
  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # BASICS
    unixtools.whereis
    fastfetch
    neovim
    killall
    niv
    age
    agenix.packages.${system}.default
    qrencode
    flameshot
    onlyoffice-bin_latest
    wget
    btop
    tree
    lm_sensors
    fanctl

    # GENERAL APPS
    obsidian
    vesktop # Discord without broken screenshare
    teams-for-linux
    zoom-us
    ferdium
    tidal-hifi
    filezilla
    vlc
  ];
}
