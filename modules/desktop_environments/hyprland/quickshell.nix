{ pkgs, lib, paths, ... }:

let
  icons = import ./icons.nix { inherit pkgs lib; };
  hyprlandConfigs = paths.hyprland_configs;

  # Any icon assigned to an `icon:`/`actionIcon:` property that matches a
  # real upstream icon must be listed in icons.nix `names`, otherwise the
  # build fails here. Only those lines are scanned, so ordinary words in
  # commands or labels (e.g. the `cat` in a Process command) are ignored.
  iconsCheck = pkgs.runCommand "rice-cc-icon-check" { } ''
    wanted=" ${lib.concatStringsSep " " icons.names} "
    fail=0
    for lit in $(grep -hE '(icon|actionIcon):' ${hyprlandConfigs + /quickshell-cc/qml}/*.qml | grep -oE '"[a-z][a-z0-9-]*"' | tr -d '"' | sort -u); do
      if [ -f "${icons.src}/icons/$lit.svg" ]; then
        case "$wanted" in
          *" $lit "*) ;;
          *) echo "quickshell QML uses icon \"$lit\" missing from icons.nix names" >&2; fail=1 ;;
        esac
      fi
    done
    [ "$fail" -eq 0 ]
    touch $out
  '';

  # The whole shell as one store path: QML plus the Lucide subset, so
  # `shellDir + "/icons/…"` resolves with no repo checkouts and no copies.
  riceCc = pkgs.runCommand "rice-cc" { } ''
    mkdir -p $out
    cp -r ${hyprlandConfigs + /quickshell-cc/qml}/* $out/
    ln -s ${icons.package}/share/lucide-icons $out/icons
  '';

  # Helper scripts the shell shells out to (ControlCenter calls them by the
  # absolute path below, so no ~/.local/bin copies are needed for these two).
  ricePower = pkgs.writeShellScriptBin "rice-power" (builtins.readFile (hyprlandConfigs + /quickshell-cc/bin/rice-power));
  riceWallpaper = pkgs.writeShellScriptBin "rice-wallpaper" (builtins.readFile (hyprlandConfigs + /quickshell-cc/bin/rice-wallpaper));
  # Bar helpers (bar clicks and Hyprland binds resolve these via PATH).
  riceClipboard = pkgs.writeShellScriptBin "rice-clipboard" (builtins.readFile (hyprlandConfigs + /quickshell-cc/bin/rice-clipboard));
  riceScreenshot = pkgs.writeShellScriptBin "rice-screenshot" (builtins.readFile (hyprlandConfigs + /quickshell-cc/bin/rice-screenshot));
  riceRecord = pkgs.writeShellScriptBin "rice-record" (builtins.readFile (hyprlandConfigs + /quickshell-cc/bin/rice-record));
  riceMedia = pkgs.writeShellScriptBin "rice-media" (builtins.readFile (hyprlandConfigs + /quickshell-cc/bin/rice-media));
  riceGpu = pkgs.writeShellScriptBin "rice-gpu" (builtins.readFile (hyprlandConfigs + /quickshell-cc/bin/rice-gpu));
in
{
  environment.systemPackages = with pkgs; [
    quickshell
    hyprsunset
    ricePower
    riceWallpaper
    riceClipboard
    riceScreenshot
    riceRecord
    riceMedia
    riceGpu
  ];

  # Quickshell needs TZDIR or a TZ value starting with ':' to resolve
  # timezone abbreviations like BST. Setting TZ here (and only for
  # quickshell) fixes the "Unable to determine system time zone" warning
  # without changing the global zone semantics.
  systemd.user.services.quickshell-rice-cc = {
    description = "Quickshell rice-cc";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "/run/current-system/sw/bin/uwsm app -- /run/current-system/sw/bin/qs -c rice-cc -n -d";
      Restart = "on-failure";
      # The bar shells out to session tools (nmcli, hyprsunset, pgrep,
      # rice-*, wofi, pavucontrol, ...). systemd user units start with a
      # minimal PATH, so give the shell the same view as a login session.
      Environment = [
        "TZDIR=/etc/zoneinfo"
        "PATH=/run/current-system/sw/bin:/usr/bin:/bin"
      ];
    };
  };

  system.checks = [ iconsCheck ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Adapted control-center subset of hyprland-cachyos-rice (quickshell).
  # Opened via: qs -c rice-cc ipc call controlcenter toggle
  environment.etc."xdg/quickshell/rice-cc".source = riceCc;

  # Quickshell only searches ~/.config and $XDG_CONFIG_DIRS, so link the
  # user config dir at the store path. Idempotent: every rebuild converges
  # ~/.config on the current generation, nothing is ever copied or merged.
  system.userActivationScripts.quickshell.text = ''
    t="$HOME/.config/quickshell/rice-cc"
    if [ ! -L "$t" ]; then
      rm -rf "$t"
    fi
    mkdir -p "$HOME/.config/quickshell"
    ln -sfn /etc/xdg/quickshell/rice-cc "$t"
  '';
}
