{ ... }:

{
  boot.kernel.sysctl = {
    # Reduce writeback flush frequency (in centiseconds).
    # Keeping it low prevents sudden I/O stalls during game asset streaming and shader
    # caching.
    "vm.dirty_writeback_centisecs" = 500;
  };

  # I/O Scheduler Configuration
  services.udev.extraRules = ''
    # Bypass scheduler for maximum throughput on NVMe drives
    SUBSYSTEM=="block",ATTR{queue/rotational}=="0",ATTR{queue/scheduler}="none"
  '';
}
