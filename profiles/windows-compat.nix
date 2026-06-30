{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    bottles
    inputs.nix-gaming.packages.${pkgs.system}.winetricks-git
    inputs.nix-gaming.packages.${pkgs.system}.wine-tkg
    inputs.nix-gaming.packages.${pkgs.system}.wineprefix-preparer
  ];
}
