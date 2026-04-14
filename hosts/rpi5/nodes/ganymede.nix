{ paths, ... }:

{
  networking.hostName = "ganymede";

  networking.interfaces.end0 = {
    ipv4.addresses = [
      { address = "192.168.1.52"; prefixLength = 24; }
    ];
    ipv6.addresses = [
      { address = "fd00::1:0:0:52"; prefixLength = 64; }
    ];
  };

  age.secrets.hostKey.file = paths.secrets + /ganymede-host-key.age;
}
