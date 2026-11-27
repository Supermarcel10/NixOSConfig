{ pkgs, lib, ... }:

let
  icons = import ./icons.nix { inherit pkgs lib; };
  # Single source of truth for desktop styling. Colours come from the wallust
  # palette (see the templates further down); anything wallust renders keeps
  # its {{ }} placeholder here and is derived at render time.
  animSpeed = "2";
  gapIn = "2";
  gapOut = "5";
  fontFamily = "JetBrainsMono Nerd Font Mono";
  fontSize = "13";
  rounding = "10";
  volumeStep = "5";
  # Attention/error tone derived from the palette accent - never hard-coded.
  # (One wallust filter chain, rendered as hex or rgb wherever needed.)
  errorChain = "color5 | saturate(0.3) | lighten(0.25)";
  errorTone = "{{${errorChain}}}";
  onErrorTone = "{{background}}";
in

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;
  programs.hyprlock.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  xdg.mime.defaultApplications = {
    "inode/directory" = "thunar.desktop";
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
          icon-theme = "Papirus-Dark";
        };
      }
    ];
  };

  # Make Qt applications (including QuickShell's platform tray menus) follow the
  # dark Adwaita theme used by GTK. QGnomePlatform reads the GNOME settings above.
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  systemd.services."drkonqi-coredump-processor@".enable = false;
  systemd.user.sockets."drkonqi-coredump-launcher".enable = false;
  systemd.user.services."drkonqi-coredump-pickup".enable = false;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = [
      "hyprland"
      "gtk"
    ];
  };

  # Kept for user scripts; rice-* helpers are system packages on PATH.
  environment.localBinInPath = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    GDK_BACKEND = "wayland,x11";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
    lucide
  ];

  environment.systemPackages = with pkgs; [
    wofi
    hyprlock
    hypridle
    hyprpaper
    hyprpolkitagent
    hyprpicker
    wallust
    grim
    slurp
    wl-clipboard
    cliphist
    file-roller
    tumbler
    papirus-icon-theme
    pavucontrol
    wireplumber
    playerctl
    brightnessctl
    jq
    libnotify
    wf-recorder
    wayland-pipewire-idle-inhibit
  ];

  environment.etc."hypr/hyprland.conf".text = ''
    monitor=DP-2,2560x1440@143.97,0x0,1.15,transform,3
    monitor=DP-1,3840x2160@143.96,1252x0,1.25

    source = ~/.config/hypr/colors.conf

    env = XCURSOR_SIZE,24
    env = QT_QPA_PLATFORM,wayland
    env = GTK_THEME,Adwaita:dark

    exec-once = uwsm app -- hyprpaper
    exec-once = ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent
    exec-once = uwsm app -- hypridle
    exec-once = uwsm app -- wayland-pipewire-idle-inhibit
    exec-once = uwsm app -- sh -c 'wl-paste --type text --watch cliphist store'
    exec-once = uwsm app -- sh -c 'wl-paste --type image --watch cliphist store'

    input {
        kb_layout = pl
        accel_profile = flat
        sensitivity = +0.25
        natural_scroll = false
        touchpad {
            natural_scroll = false
        }
    }

    general {
        gaps_in = ${gapIn}
        gaps_out = ${gapOut}
        border_size = 2
        col.active_border = $color6 $color5 45deg
        col.inactive_border = $color1
        layout = dwindle
    }

    decoration {
        rounding = ${rounding}
        active_opacity = 1.0
        inactive_opacity = 1.0
        shadow {
            enabled = true
            range = 6
            render_power = 3
        }
        blur {
            enabled = true
            size = 8
            passes = 2
            new_optimizations = true
        }
    }

    animations {
        enabled = true
        animation = global, 1, ${animSpeed}, default
    }

    dwindle {
        preserve_split = true
    }

    misc {
        force_default_wallpaper = 0
        disable_hyprland_logo = true
    }

    xwayland {
        force_zero_scaling = true
    }

    debug {
        disable_scale_checks = true
    }

    $mainMod = SUPER

    bind = $mainMod, Return, exec, uwsm app -- kitty
    bind = $mainMod, Space, exec, sh -c 'pkill -x \.wofi-wrapped || uwsm app -- wofi --show drun'
    bind = $mainMod, E, exec, uwsm app -- thunar
    bind = $mainMod, Q, killactive,
    bind = ALT, F4, killactive,
    bind = $mainMod, F, fullscreen,
    bind = $mainMod, V, togglefloating,
    bind = $mainMod, P, pseudo,
    bind = $mainMod, L, exec, uwsm app -- hyprlock
    bind = $mainMod, C, exec, qs -c rice-cc ipc call controlcenter toggle
    bind = $mainMod, N, exec, qs -c rice-cc ipc call notifications toggle
    bind = , Print, exec, uwsm app -- rice-screenshot
    bind = $mainMod, S, exec, uwsm app -- rice-screenshot

    # Plain commands: the Quickshell OSD watches PipeWire itself,
    # so nothing here asks for feedback to appear.
    bindel = , XF86AudioRaiseVolume, exec, uwsm app -- wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ ${volumeStep}%+
    bindel = , XF86AudioLowerVolume, exec, uwsm app -- wpctl set-volume @DEFAULT_AUDIO_SINK@ ${volumeStep}%-
    bindl = , XF86AudioMute, exec, uwsm app -- wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindl = , XF86AudioMicMute, exec, uwsm app -- wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    bindel = , XF86MonBrightnessUp, exec, uwsm app -- brightnessctl -q s +5%
    bindel = , XF86MonBrightnessDown, exec, uwsm app -- brightnessctl -q s 5%-
    bindl = , XF86AudioPlay, exec, uwsm app -- rice-media play-pause
    bindl = , XF86AudioNext, exec, uwsm app -- rice-media next
    bindl = , XF86AudioPrev, exec, uwsm app -- rice-media previous
    bindl = , XF86AudioStop, exec, uwsm app -- playerctl stop

    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9

    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d
    bind = $mainMod SHIFT, left, movewindow, mon:DP-2
    bind = $mainMod SHIFT, right, movewindow, mon:DP-1
    bind = $mainMod CTRL, left, swapwindow, l
    bind = $mainMod CTRL, right, swapwindow, r
    bind = $mainMod CTRL, up, swapwindow, u
    bind = $mainMod CTRL, down, swapwindow, d

    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    windowrule = match:class ^(pavucontrol|nm-connection-editor)$, float on
    windowrule = match:class .*, suppress_event maximize
    windowrule = match:fullscreen 1, idle_inhibit fullscreen
  '';

  environment.etc."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
        ignore_dbus_inhibit = false
        ignore_systemd_inhibit = false
    }

    listener {
        timeout = 300
        on-timeout = loginctl lock-session
    }

    listener {
        timeout = 330
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
    }
  '';

  environment.etc."hypr/hyprpaper.conf".text = ''
    wallpaper {
        monitor = DP-1
        path = /home/marcel/.nixos/wallpapers/wallhaven-5y3e69_3840x2160.png
        fit_mode = cover
    }
    wallpaper {
        monitor = DP-2
        path = /home/marcel/.nixos/wallpapers/wallhaven-5y3e69_3840x2160.png
        fit_mode = cover
    }
  '';

  environment.etc."wallust/templates/hyprland-colors".text = ''
    $background = rgb({{background | strip}})
    $foreground = rgb({{foreground | strip}})
    $cursor = rgb({{cursor | strip}})
    $color0 = rgb({{color0 | strip}})
    $color1 = rgb({{color1 | strip}})
    $color2 = rgb({{color2 | strip}})
    $color3 = rgb({{color3 | strip}})
    $color4 = rgb({{color4 | strip}})
    $color5 = rgb({{color5 | strip}})
    $color6 = rgb({{color6 | strip}})
    $color7 = rgb({{color7 | strip}})
    $color8 = rgb({{color8 | strip}})
    $color9 = rgb({{color9 | strip}})
    $color10 = rgb({{color10 | strip}})
    $color11 = rgb({{color11 | strip}})
    $color12 = rgb({{color12 | strip}})
    $color13 = rgb({{color13 | strip}})
    $color14 = rgb({{color14 | strip}})
    $color15 = rgb({{color15 | strip}})
  '';

  environment.etc."wofi/config".text = ''
    allow_images=true
    image_size=32
    no_actions=true
    width=600
    lines=10
    location=center
    orientation=vertical
    matching=fuzzy
    insensitive=true
    prompt=
  '';

  environment.etc."wallust/templates/wofi-style".text = ''
    window {
        background-color: rgba({{background | rgb}}, 0.85);
        border: 2px solid {{color5}};
        border-radius: 12px;
        font-family: "${fontFamily}";
        font-size: ${fontSize}px;
    }
    #outer-box {
        background-color: transparent;
        margin: 8px;
    }
    #inner-box {
        background-color: transparent;
    }
    #scroll {
        background-color: transparent;
    }
    #input {
        background-color: rgba({{color1 | rgb}}, 0.9);
        color: {{foreground}};
        border: none;
        border-radius: 8px;
        margin: 8px;
        padding: 6px;
    }
    #entry {
        padding: 6px;
        border-radius: 8px;
    }
    #entry:selected {
        background-color: {{color5}};
    }
    #entry:selected #text {
        color: {{background}};
    }
    #text {
        color: {{foreground}};
    }
    #img {
        margin-right: 8px;
        background-color: transparent;
    }
  '';


  environment.etc."wallust/templates/hyprpaper".text = ''
    wallpaper {
        monitor = DP-1
        path = {{wallpaper}}
        fit_mode = cover
    }
    wallpaper {
        monitor = DP-2
        path = {{wallpaper}}
        fit_mode = cover
    }
  '';

  environment.etc."wallust/templates/quickshell-colors".text = ''
    {
      "primary": "{{color5}}",
      "on_primary": "{{background}}",
      "primary_container": "{{color3}}",
      "on_primary_container": "{{color15}}",
      "primary_fixed": "{{color6}}",
      "secondary": "{{color2}}",
      "tertiary": "{{color4}}",
      "error": "${errorTone}",
      "on_error": "${onErrorTone}",
      "surface": "{{background}}",
      "surface_container_lowest": "{{color0}}",
      "surface_container_low": "{{background}}",
      "surface_container": "{{background}}",
      "surface_container_high": "{{color0}}",
      "surface_container_highest": "{{color1}}",
      "on_surface": "{{foreground}}",
      "on_surface_variant": "{{color7}}",
      "outline": "{{color2}}",
      "outline_variant": "{{color1}}",
      "font": "${fontFamily}",
      "mono": "${fontFamily}"
    }
  '';

  environment.etc."wallust/wallust.toml".text = ''
    backend = "fastresize"
    color_space = "salience"
    palette = "saliencedark"

    [templates]
    hyprland = { template = 'hyprland-colors', target = '~/.config/hypr/colors.conf' }
    hyprpaper = { template = 'hyprpaper', target = '~/.config/hypr/hyprpaper.conf' }
    wofi = { template = 'wofi-style', target = '~/.config/wofi/style.css' }
    quickshell = { template = 'quickshell-colors', target = '~/.cache/rice/quickshell-colors.json' }
  '';

  system.userActivationScripts.hyprland.text = ''
    rm -f "$HOME/.config/hypr/hyprland.lua"
    # Static configs converge every rebuild via symlink (copy-once left
    # stale files behind, then no restore after a delete). Links are only
    # recreated when pointing elsewhere, so steady-state rebuilds fire no
    # file events and never race Hyprland's config watcher. Wallust-owned
    # targets (hyprpaper.conf, colors.conf, wofi style) stay real files
    # since wallust rewrites them on every wallpaper change.
    for f in hyprland.conf hypridle.conf; do
      t="$HOME/.config/hypr/$f"
      if [ "$(readlink "$t" 2>/dev/null)" != "/etc/hypr/$f" ]; then
        rm -rf "$t"
        mkdir -p "$HOME/.config/hypr"
        ln -s "/etc/hypr/$f" "$t"
      fi
    done
    t="$HOME/.config/wofi/config"
    if [ "$(readlink "$t" 2>/dev/null)" != "/etc/wofi/config" ]; then
      rm -rf "$t"
      mkdir -p "$HOME/.config/wofi"
      ln -s /etc/wofi/config "$t"
    fi
    if [ ! -e "$HOME/.config/hypr/hyprpaper.conf" ]; then
      mkdir -p "$HOME/.config/hypr"
      cp /etc/hypr/hyprpaper.conf "$HOME/.config/hypr/hyprpaper.conf"
    fi
    if [ ! -e "$HOME/.config/wallust/templates/hyprland-colors" ]; then
      mkdir -p "$HOME/.config/wallust/templates"
      cp /etc/wallust/templates/hyprland-colors "$HOME/.config/wallust/templates/hyprland-colors"
    fi
    if [ ! -e "$HOME/.config/wallust/templates/hyprpaper" ]; then
      mkdir -p "$HOME/.config/wallust/templates"
      cp /etc/wallust/templates/hyprpaper "$HOME/.config/wallust/templates/hyprpaper"
    fi
    if [ ! -e "$HOME/.config/wallust/templates/wofi-style" ]; then
      mkdir -p "$HOME/.config/wallust/templates"
      cp /etc/wallust/templates/wofi-style "$HOME/.config/wallust/templates/wofi-style"
    fi
    if [ ! -e "$HOME/.config/wallust/templates/quickshell-colors" ]; then
      mkdir -p "$HOME/.config/wallust/templates"
      cp /etc/wallust/templates/quickshell-colors "$HOME/.config/wallust/templates/quickshell-colors"
    fi
    # Waybar is gone (QS bar only): drop stale copies so the system
    # rice-* packages on PATH win and old configs do not linger.
    rm -rf "$HOME/.config/waybar"
    rm -f "$HOME/.config/wallust/templates/waybar-style"
    rm -f "$HOME/.config/hypr/hyprland.conf.autogen-bak"
    for b in rice-clipboard rice-screenshot rice-record rice-media; do
      rm -f "$HOME/.local/bin/$b"
    done
  '';
}
