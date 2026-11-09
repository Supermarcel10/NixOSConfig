{ pkgs, ... }:

{
  # TOTP / 2FA + YubiKey-ready security baseline.
  # Secrets themselves stay OUT of the nix store / git.
  # Only packages + hardware support are declarative here.
  # KeePassXC database lives at ~/Documents/2fa.kdbx (password now,
  # password + YubiKey challenge-response later).

  environment.systemPackages = with pkgs; [
    keepassxc
    oath-toolkit # oathtool --totp for verification only, no storage
    yubikey-manager # ykman CLI, inert until a key is plugged in
    yubioath-flutter # Yubico Authenticator GUI, inert until a key is plugged in
  ];

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  hardware.gpgSmartcards.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Future YubiKey login - DO NOT enable until 2 keys are enrolled
  # and backup codes are stored offline:
  # security.pam.u2f.enable = true;
  # security.pam.services.login.u2fAuth = true;
  # security.pam.services.sudo.u2fAuth = true;
}
