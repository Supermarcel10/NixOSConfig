{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    bottles
    winetricks
    inputs.nix-gaming.packages.${pkgs.system}.wine-ge
  ];
}
