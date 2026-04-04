{ paths, ... }:

{
  networking.hostName = "calisto";

  age.secrets.hostKey.file = paths.secrets + /calisto-host-key.age;
  age.secrets.ageKey.file  = paths.secrets + /calisto-age-key.age;
}
