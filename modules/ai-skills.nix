{ paths, ... }:

{
  # Symlink skills into opencode's expected location.
  systemd.tmpfiles.rules = [
    "L+ /home/marcel/.config/opencode/skills - - - - ${paths.skills}"
  ];
}
