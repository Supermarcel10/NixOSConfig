{ paths, ... }:

{
  networking.hostName = "calisto";

  networking.interfaces.end0 = {
    ipv4.addresses = [
      { address = "192.168.1.50"; prefixLength = 24; }
    ];
    ipv6.addresses = [
      { address = "fd00::1:0:0:50"; prefixLength = 64; }
    ];
  };

  age.secrets.hostKey.file = paths.secrets + /calisto-host-key.age;
}
