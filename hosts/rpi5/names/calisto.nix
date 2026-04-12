{ paths, ... }:

{
  networking.hostName = "calisto";

  age.secrets.hostKey.file = paths.secrets + /calisto-host-key.age;
}
