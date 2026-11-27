{ lib, pkgs, ... }:

# TUI alternative to regreet without any compositors involved
{
  imports = [ ./greetd.nix ];

  services.greetd.settings.default_session = {
    command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-user-session --asterisks --cmd 'uwsm start hyprland-uwsm.desktop'";
    user = "greeter";
  };
}
