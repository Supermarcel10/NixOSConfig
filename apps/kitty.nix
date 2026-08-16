{ pkgs, ... }:

let
  kitty-ssh = pkgs.writeShellScriptBin "kitty-ssh" ''
    if [ -n "$KITTY_WINDOW_ID" ]; then
      exec ${pkgs.kitty}/bin/kitty +kitten ssh "$@"
    else
      exec ssh "$@"
    fi
  '';
in

{
  environment.systemPackages = with pkgs; [
    kitty
    kitty-ssh
  ];

  environment.variables = {
    TERMINAL = "kitty";
  };

  environment.shellAliases = {
    ssh = "kitty-ssh";
  };
}
