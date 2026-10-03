{ ... }:

{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;

    # Focusrite Scarlett 2i2 Gen 4
    extraConfig.pipewire."92-scarlett-2i2-gen4" = {
      "context.properties" = {
        "default.clock.rate" = 192000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 192000 ];
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 4096;
      };
    };

    wireplumber.extraConfig."10-scarlett-2i2-gen4" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "node.name" = "~alsa_input.usb-Focusrite_Scarlett_2i2_4th_Gen.*"; }
            { "node.name" = "~alsa_output.usb-Focusrite_Scarlett_2i2_4th_Gen.*"; }
          ];
          actions = {
            update-props = {
              "audio.rate" = 192000;
            };
          };
        }
      ];
    };
  };
}
