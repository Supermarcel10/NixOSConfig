{ lib, ... }:

{
  powerManagement.cpuFreqGovernor = lib.mkForce "powersave";

  boot = {
    kernel.sysctl = {
      # Higher value keeps tasks on same core/socket, reducing cache misses.
      # 5ms is safe for Zen3/Zen4 (default ~500µs can cause migration thrashing).
      "kernel.sched_migration_cost_ns" = 5000000;

      # Games prefer explicit priority control over automatic grouping.
      "kernel.sched_autogroup_enabled" = 0;
    };
  };
}
