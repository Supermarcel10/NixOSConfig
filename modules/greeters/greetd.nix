{ ... }:

# Shared base for all greeters
# greetd itself + GNOME Keyring auto-unlock wiring
{
  services.greetd.enable = true;

  security.pam.services.greetd.enableGnomeKeyring = true;
}
