{ config, ... }:

{
  # Automatically free /nix/store weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-old";
    persistent = true;
    randomizedDelaySec = "1h";
  };

  # Deduplicate identical files in /nix/store
  nix.settings.auto-optimise-store = true;

  # Keep /boot small
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.grub.configurationLimit = 5;

  systemd.services.prune-system-generations = {
    description = "Prune NixOS system generations, keep last 5";
    requires = [ "nix-daemon.socket" ];
    after = [ "nix-daemon.socket" ];
    requiredBy = [ "nix-gc.service" ];
    before = [ "nix-gc.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${config.nix.package}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations '+5'
    '';
  };
}
