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

  systemd.user.services.hide-steam-games = {
    description = "Hide Steam games from app launchers";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      for f in "$HOME"/.local/share/applications/*.desktop; do
        if grep -q '^Exec=steam steam://rungameid' "$f" && ! grep -q '^NoDisplay=true' "$f"; then
          printf '\nNoDisplay=true\n' >> "$f"
        fi
      done
    '';
  };

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
