{ pkgs, inputs, paths, unstable, ... }:

{
  imports = [
    (paths.apps + /kitty.nix)
    (paths.apps + /firefox.nix)
    (paths.apps + /via.nix)
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://nix-gaming.cachix.org"
    ];
    trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    # BASICS
    unixtools.whereis
    fastfetch
    neovim
    killall
    niv
    age
    parted
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    qrencode
    onlyoffice-desktopeditors
    wget
    btop-rocm
    tree
    direnv
    lm_sensors
    fanctl
    ripgrep
    imagemagick

    # GENERAL APPS
    obsidian
    unstable.grayjay
    obs-studio
    unstable.legcord # Discord replacement
    whatsapp-electron
    stoat-desktop
    teams-for-linux
    zoom-us
    unstable.sone
    filezilla
    mpv
    texlab
    texliveFull
    inkscape
  ];
}
