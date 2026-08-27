{ config, pkgs, lib, inputs, ... }:

with lib;

let
  wine = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wine-tkg;
  wineprefix-preparer = inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wineprefix-preparer;
  deps = import ./deps.nix { inherit pkgs; };
  setup = import ./setup.nix { inherit pkgs deps wine wineprefix-preparer; };
  launcher = import ./launcher.nix { inherit pkgs wine; };
in
{
  options.on1-photo-raw = {
    enable = mkEnableOption "ON1 Photo RAW 2026.4";
  };

  config = mkIf config.on1-photo-raw.enable {
    environment.systemPackages = [
      setup
      launcher
    ];
  };
}
