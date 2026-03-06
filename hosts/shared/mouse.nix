{ ... }:

{
  services.libinput = {
    enable = true;

    mouse = {
      accelProfile = "flat";
      naturalScrolling = false;
    };

    touchpad = {
      accelProfile = "flat";
      naturalScrolling = false;
      scrollMethod = "twofinger";
      # TODO: Find a way to set "Integrated Right Click"
    };
  };
}
