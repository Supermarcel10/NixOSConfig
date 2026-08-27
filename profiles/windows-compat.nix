{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    bottles
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.winetricks-git
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wine-tkg
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wineprefix-preparer
  ];
}
