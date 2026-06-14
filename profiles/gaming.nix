{ pkgs, ... }:

{
  imports = [
    ./windows-compat.nix
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    (lutris.override {
      extraPkgs = pkgs: [
        gamescope
        gamemode
        mangohud
      ];
    })

    gamescope
    mangohud
    prismlauncher
  ];
}
