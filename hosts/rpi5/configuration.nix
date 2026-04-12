{
  pkgs,
  paths,
  nixos-raspberrypi,
  ...
}:

{
  imports = with nixos-raspberrypi.nixosModules; [
    raspberry-pi-5.base
    raspberry-pi-5.page-size-16k  # 16K page-size optimisations

    (paths.modules + /locale.nix)
    (paths.modules + /networking.nix)
  ];

  boot.loader.raspberry-pi.firmwarePath = "/boot/firmware";
  boot.loader.raspberry-pi.bootloader = "kernel";

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  # agenix secrets
  age.secrets.hostKey = {
    path  = "/etc/ssh/ssh_host_ed25519_key";
    mode  = "0600";
    owner = "root";
  };

  age.identityPaths = [ "/etc/age/key.txt" ];

  users.users.worker = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [
      ./keys/pi_cluster.pub
    ];
  };

  services.openssh = {
    enable = true;
    hostKeys = [ ]; # disable auto-generated host keys
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  environment.systemPackages = with pkgs; [
    neovim
    git
    gh
    wget
    unixtools.whereis
    fastfetch
    btop
    ripgrep

    docker
  ];

  system.stateVersion = "25.05";
}
