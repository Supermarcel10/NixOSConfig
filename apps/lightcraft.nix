{ config, pkgs, lib, inputs, ... }:

with lib;

let
  lightcraft-pkg = inputs.lightcraft.packages.${pkgs.stdenv.hostPlatform.system}.lightcraft.overrideAttrs {
    doCheck = false;
  };
in
{
  options.lightcraft = {
    enable = mkEnableOption "LightCraft photo editor (upstream flake)";
  };

  config = mkIf config.lightcraft.enable {
    environment.systemPackages = [
      lightcraft-pkg
    ];
  };
}
