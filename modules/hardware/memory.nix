{ ... }:

{
  # Gives the kernel a fast swap outlet so it can move cold pages out of
  # physical RAM before reaching OOM, preventing hard freezes.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.kernel.sysctl = {
    # 180 = aggressive zram swap (upstream default for CachyOS)
    # 150 = gaming-optimized (move pages to swap early, keep RAM free)
    # 160 = safe middle ground that works for both scenarios
    "vm.swappiness" = 160;

    # Disable swap read-ahead for zram. Read-ahead makes sense for slow disk
    # swap (amortises seek cost) but wastes RAM on zram where random access is
    # already fast.
    "vm.page-cluster" = 0;

    # Keep inode/dentry caches around longer relative to page reclaim.
    # Default 100 is too aggressive for a desktop; 50 reduces unnecessary
    # cache drops that cause latency spikes.
    "vm.vfs_cache_pressure" = 50;

    # Start writing dirty pages to disk at 5% RAM (rather than default 20%).
    # Reduces the size of dirty page bursts that can cause momentary freezes
    # during heavy write workloads.
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;

    # Increase max map count for wine/proton (needs more memory mappings).
    # Default 65536 can be limiting for complex games; 262144 is safe.
    "vm.max_map_count" = 262144;
  };

  # Nix build memory safety net.
  # Together these prevent a pile of parallel builds from exhausting RAM.
  nix.settings = {
    min-free = 1073741824;  # 1 GiB
    max-free = 4294967296;  # 4 GiB
  };
}
