{ ... }:

{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix.settings = {
    trusted-users = [ "root" "marcel" ];
    extra-platforms = [ "aarch64-linux" ];
  };
}
