{ pkgs, inputs, paths, ... }:

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
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    qrencode
    flameshot
    onlyoffice-desktopeditors
    wget
    btop-rocm
    tree
    direnv
    lm_sensors
    fanctl
    ripgrep
    imagemagick
    lact

    # GENERAL APPS
    obsidian
    grayjay
    obs-studio
    (pkgs.blender.override {
      cudaSupport = true;
      inherit (pkgs) cudaPackages;
    })
    legcord # Discord replacement
    (pkgs.stoat-desktop.override {
      electron_38 = pkgs.electron;
    })
    teams-for-linux
    zoom-us
    tidal-hifi
    filezilla
    mpv
    texlab
    texliveFull
    inkscape
  ];

  systemd.services.lact = {
    description = "AMDGPU Control Daemon";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    enable = true;
  };
}
