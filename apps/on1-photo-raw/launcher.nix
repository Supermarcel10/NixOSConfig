{ pkgs, wine }:

let
  on1Exe = "$HOME/.local/share/on1-photo-raw/wine-prefix/drive_c/Program Files/ON1/ON1 Photo RAW 2026.4/ON1 Photo RAW 2026.4.exe";

  on1-launcher = pkgs.writeShellApplication {
    name = "on1-photo-raw";
    runtimeInputs = [ wine ];
    text = ''
      WINEPREFIX="$HOME/.local/share/on1-photo-raw/wine-prefix"
      WINE="${wine}/bin/wine"

      if [ ! -f "${on1Exe}" ]; then
        echo "Error: ON1 Photo RAW not found at ${on1Exe}"
        echo ""
        echo "Have you run the setup?"
        echo "  setup-on1-photo-raw <path-to-on1-installer.exe>"
        exit 1
      fi

      export WINEPREFIX
      export WINE
      "$WINE" "${on1Exe}" "$@"
    '';
  };

  on1-desktop = pkgs.makeDesktopItem {
    name = "on1-photo-raw";
    desktopName = "ON1 Photo RAW 2026.4";
    comment = "All-in-One Raw Photo Editor";
    exec = "${on1-launcher}/bin/on1-photo-raw %F";
    icon = "image-x-generic";
    categories = [ "Graphics" "Photography" ];
    mimeTypes = [ "image/jpeg" "image/png" "image/tiff" "image/x-canon-cr2" "image/x-nikon-nef" "image/x-sony-arw" ];
  };
in
  pkgs.symlinkJoin {
    name = "on1-photo-raw-launcher";
    paths = [ on1-launcher on1-desktop ];
  }
