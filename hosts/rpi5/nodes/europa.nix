{ paths, ... }:

{
  networking.hostName = "europa";

  age.secrets.hostKey.file = paths.secrets + /europa-host-key.age;
}
