{ ... }:

{
  environment.shellAliases = {
    # Unstable nix-shell
    unstable-nix-shell = "nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixpkgs-unstable.tar.gz";

    # QR Code Generation
    qr = "qrencode -t ansiutf8";

    # ripgrep Alias
    grep = "rg";
    original_grep = "grep";

    # ImageMagick Conversion
    convert = "magick";

    # Change Directory Aliases
    desktop = "cd ~/Desktop/";
    downloads = "cd ~/Downloads/";

    # NixOS
    nfu = "nix flake update";
    nrs = "sudo nixos-rebuild switch --flake ~/.nixos#$(hostname)";
    nrb = "sudo nixos-rebuild boot --flake ~/.nixos#$(hostname)";
    nrbf = "nfu && nrb";
  };
}
