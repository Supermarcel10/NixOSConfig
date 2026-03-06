{ ... }:

{
  # COSMIC Login Manager
  services.displayManager.cosmic-greeter.enable = true;

  # COSMIC Desktop Environment
  services.desktopManager.cosmic.enable = true;

  # System76 Scheduler (Slight Performance Uplift)
  services.system76-scheduler.enable = true;
}
