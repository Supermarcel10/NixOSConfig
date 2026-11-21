{ pkgs, lib }:

let
  # Tracks the font package so the Quickshell font and the SVGs can
  # never drift apart. On a nixpkgs bump, update `hash` with:
  #   nix-prefetch-url --unpack https://registry.npmjs.org/lucide-static/-/lucide-static-<version>.tgz
  version = pkgs.lucide.version;

  src = pkgs.fetchzip {
    url = "https://registry.npmjs.org/lucide-static/-/lucide-static-${version}.tgz";
    hash = "sha256-mBeO8NhPOQjWNScprXVqsTzWbBVFpRFd0jg2s8r3yuo=";
  };

  # Every icon referenced by Quickshell QML (icon:/actionIcon:).
  # quickshell.nix fails the build if QML references anything outside this list.
  names = [
    "audio-lines"
    "bell"
    "bell-off"
    "bell-ring"
    "check"
    "chevron-left"
    "chevron-right"
    "clipboard-list"
    "cpu"
    "disc"
    "ethernet-port"
    "gauge"
    "gpu"
    "headphones"
    "headset"
    "keyboard"
    "layout-grid"
    "leaf"
    "loader-circle"
    "lock"
    "memory-stick"
    "mic"
    "mic-off"
    "moon-star"
    "music"
    "palette"
    "pause"
    "play"
    "power"
    "refresh-cw"
    "speaker"
    "sun"
    "trash-2"
    "triangle-alert"
    "volume"
    "volume-1"
    "volume-2"
    "volume-x"
    "wifi"
    "wifi-high"
    "wifi-low"
    "wifi-off"
    "wifi-zero"
    "x"
    "zap"
  ];

  # Font codepoints for the Lucide.ttf shipped as pkgs.lucide (same `version`
  # as the SVGs above). Regenerate with:
  #   nix-shell -p python3Packages.fonttools --run "python3 -c \"
  #   from fontTools.ttLib import TTFont;
  #   f = TTFont('\$(nix build nixpkgs#lucide --no-link --print-out-paths)/share/fonts/truetype/Lucide.ttf');
  #   rev = {v:k for k,v in f.getBestCmap().items() if k > 128};
  #   print({n: '%04X' % rev[n] for n in wanted})\""
  # Hex + fromJSON keeps raw PUA bytes out of the source.
  codes = {
    "audio-lines" = "E55A";
    "bell" = "E059";
    "bell-off" = "E05A";
    "bell-ring" = "E224";
    "check" = "E06C";
    "chevron-left" = "E06E";
    "chevron-right" = "E06F";
    "clipboard-list" = "E086";
    "cpu" = "E0A9";
    "ethernet-port" = "E620";
    "gauge" = "E1BF";
    "gpu" = "E66A";
    "headphones" = "E0F1";
    "headset" = "E5BD";
    "keyboard" = "E284";
    "layout-grid" = "E0FF";
    "leaf" = "E2DE";
    "loader-circle" = "E10A";
    "lock" = "E10B";
    "memory-stick" = "E445";
    "mic" = "E118";
    "mic-off" = "E119";
    "moon-star" = "E410";
    "music" = "E122";
    "palette" = "E1DD";
    "pause" = "E12E";
    "play" = "E13C";
    "power" = "E140";
    "refresh-cw" = "E145";
    "speaker" = "E166";
    "sun" = "E178";
    "trash-2" = "E18E";
    "triangle-alert" = "E193";
    "volume" = "E1A9";
    "volume-1" = "E1AA";
    "volume-2" = "E1AB";
    "volume-x" = "E1AC";
    "wifi" = "E1AE";
    "wifi-high" = "E5F7";
    "wifi-low" = "E5F8";
    "wifi-off" = "E1AF";
    "wifi-zero" = "E5F9";
    "x" = "E1B2";
    "zap" = "E1B4";
  };

  glyphs = lib.mapAttrs (_name: code: builtins.fromJSON ''"\u${code}"'') codes;

  package = pkgs.runCommand "lucide-icons-subset-${version}" { } ''
    mkdir -p $out/share/lucide-icons
    for n in ${lib.escapeShellArgs names}; do
      cp "${src}/icons/$n.svg" "$out/share/lucide-icons/$n.svg"
    done
  '';
in
{
  inherit version src names codes glyphs package;
}
