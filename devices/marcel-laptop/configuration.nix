{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # TODO: Find a neater way to have neater shared configs
    ./../shared/configuration.nix
    ./../shared/desktop_environments/kde_plasma/environment.nix
    ./../shared/printing.nix

    # TODO: Find a neater way to have app profiles
    ./../../profiles/generic.nix
    ./../../profiles/development.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-5479720c-0790-4899-8b02-f34d9828a312".device =
    "/dev/disk/by-uuid/5479720c-0790-4899-8b02-f34d9828a312";
  networking.hostName = "marcel-laptop";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marcel = {
    isNormalUser = true;
    description = "marcel";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # DO NOT CHANGE STATE WITHOUT READING DOCS!
  system.stateVersion = "24.11";
}
