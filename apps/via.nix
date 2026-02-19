{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    via
  ];

  services.udev.packages = with pkgs; [
    vial
    via
  ];
}
