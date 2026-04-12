{ paths, ... }:

{
  networking.hostName = "ganymede";

  age.secrets.hostKey.file = paths.secrets + /ganymede-host-key.age;
}
