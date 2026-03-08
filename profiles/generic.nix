{ pkgs, agenix, unstable, paths, ... }:
{
  imports = [
    (paths.apps + /kitty.nix)
    (paths.apps + /firefox.nix)
    (paths.apps + /via.nix)
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    # BASICS
    unixtools.whereis
    fastfetch
    neovim
    killall
    niv
    age
    agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    qrencode
    flameshot
    onlyoffice-desktopeditors
    wget
    btop-rocm
    tree
    lm_sensors
    fanctl
    ripgrep
    imagemagick
    unstable.lact

    # GENERAL APPS
    obsidian
    unstable.grayjay
    obs-studio
    (pkgs.blender.override {
      cudaSupport = true;
      inherit (pkgs) cudaPackages;
    })
    legcord # Discord replacement
    teams-for-linux
    zoom-us
    unstable.tidal-hifi
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
      ExecStart = "${unstable.lact}/bin/lact daemon";
    };
    enable = true;
  };
}
