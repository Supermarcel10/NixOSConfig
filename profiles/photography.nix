{ pkgs, ... }:

{
  imports = [
    ./windows-compat.nix
    ../apps/on1-photo-raw/default.nix
  ];

  on1-photo-raw.enable = true;

  environment.systemPackages = with pkgs; [
    # Core raw processing
    darktable
    rawtherapee

    # Advanced editing
    gimp
    gmic

    digikam       # Digital asset manager
    upscayl       # AI upscaling
    exiftool      # Metadata R/W
    hugin         # Panorama stitching
    lensfun       # Lens correction database
  ];
}
