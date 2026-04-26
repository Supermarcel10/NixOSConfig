{ ... }:

{
  boot.extraModprobeConfig = ''
    # Audio: Disable power saving on HDA to prevent crackling/latency
    options snd_hda_intel power_save=0
  '';
}
