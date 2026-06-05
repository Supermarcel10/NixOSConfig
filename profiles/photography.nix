{ pkgs, ... }:

{
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
