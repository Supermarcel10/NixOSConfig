{ pkgs, paths, nixos-raspberrypi, ... }:

{
  imports = with nixos-raspberrypi.nixosModules; [
    raspberry-pi-5.base
    raspberry-pi-5.page-size-16k  # 16K page-size optimisations

    (paths.modules + /locale.nix)
    (paths.modules + /networking.nix)
  ];

  boot.loader.raspberryPi.bootloader = "kernel";

  fileSystems."/" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  networking.hostName = "rpi5";
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

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
