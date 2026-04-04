{ paths, ... }:

{
  networking.hostName = "ganymede";

  age.secrets.hostKey.file = paths.secrets + /ganymede-host-key.age;
  age.secrets.ageKey.file  = paths.secrets + /ganymede-age-key.age;
}
