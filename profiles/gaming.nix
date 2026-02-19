{ pkgs, ... }:

{
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
        wineWowPackages.waylandFull
      ];
    })

    gamescope
    mangohud
    prismlauncher
    the-powder-toy
  ];
}
