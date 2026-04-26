{ ... }:

{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.kernel.sysctl = {
    # High swappiness is counter-intuitive but correct for zram: since zram is
    # fast (in-memory), eagerly moving cold pages there frees physical RAM
    # early and prevents the kernel from stalling at the OOM boundary.
    # Value of 180 is the upstream recommendation for zram systems (used by
    # CachyOS, Fedora, Android, ChromeOS).
    "vm.swappiness" = 180;

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
  };

  # Nix build memory safety net.
  # Together these prevent a pile of parallel builds from exhausting RAM.
  nix.settings = {
    min-free = 1073741824;  # 1 GiB
    max-free = 4294967296;  # 4 GiB
  };
}
