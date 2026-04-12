{ paths, ... }:

{
  programs.ssh = {
    # SSH Known Host Fingerprints
    knownHosts = {
      # Raspberry Pi Cluster
      "calisto" = {
        hostNames = [ "calisto" "192.168.1.50" ];
        publicKeyFile = paths.hosts + /rpi5/keys/calisto_host_key.pub;
      };
      "europa" = {
        hostNames = [ "europa" "192.168.1.51" ];
        publicKeyFile = paths.hosts + /rpi5/keys/europa_host_key.pub;
      };
      "ganymede" = {
        hostNames = [ "ganymede" "192.168.1.52" ];
        publicKeyFile = paths.hosts + /rpi5/keys/ganymede_host_key.pub;
      };
    };

    # SSH Client Configuration
    extraConfig = ''
      # Raspberry Pi Cluster
      Host calisto
        HostName 192.168.1.50
        User worker
        IdentityFile ~/.ssh/pi_cluster
        StrictHostKeyChecking yes

      Host europa
        HostName 192.168.1.51
        User worker
        IdentityFile ~/.ssh/pi_cluster
        StrictHostKeyChecking yes

      Host ganymede
        HostName 192.168.1.52
        User worker
        IdentityFile ~/.ssh/pi_cluster
        StrictHostKeyChecking yes
    '';
  };
}
