{ pkgs, ... }:

{
  imports = [ ./greetd.nix ];

  programs.regreet = {
    enable = true;

    # TODO: Figure out if the theme can be shared somehow
    # Match the Hyprland theme
    theme.name = "Adwaita-dark";
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
      size = 13;
    };

    settings = {
      background = {
        path = "/etc/greetd/wallpaper.png";
        fit = "Cover";
      };
      GTK.application_prefer_dark_theme = true;
    };
  };

  # Bundle wallpaper in the store, since greeter runs as its own user and cannot read $HOME.
  environment.etc."greetd/wallpaper.png".source =
    ../../wallpapers/wallhaven-5y3e69_3840x2160.png;
}
