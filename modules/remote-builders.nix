{ ... }:

{
  nix.buildMachines = [
    {
      hostName = "calisto";
      system = "aarch64-linux";
      protocol = "ssh";
      sshUser = "worker";
      sshKey = "/home/marcel/.ssh/pi_cluster";
      maxJobs = 4;
      speedFactor = 100;
      supportedFeatures = [ "big-parallel" ];
    }
    {
      hostName = "europa";
      system = "aarch64-linux";
      protocol = "ssh";
      sshUser = "worker";
      sshKey = "/home/marcel/.ssh/pi_cluster";
      maxJobs = 2;
      speedFactor = 1;
      supportedFeatures = [ "big-parallel" ];
    }
    {
      hostName = "ganymede";
      system = "aarch64-linux";
      protocol = "ssh";
      sshUser = "worker";
      sshKey = "/home/marcel/.ssh/pi_cluster";
      maxJobs = 2;
      speedFactor = 1;
      supportedFeatures = [ "big-parallel" ];
    }
  ];
}
