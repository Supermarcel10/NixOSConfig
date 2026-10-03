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
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 96000 192000 ];
        "default.clock.quantum" = 512;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 4096;
      };
    };

    # NOTE: no per-node api.alsa.period-size/headroom overrides.
    # Those left the Pro profile with QUANT/RATE 0 and streams in [init].
  };
}
