{ config, lib, ... }:

let
  cfg = config.cluster.k3s;
in
{
  options.cluster.k3s = {
    enable = lib.mkEnableOption "K3s cluster node";

    role = lib.mkOption {
      type = lib.types.enum [ "bootstrap" "server" ];
      default = "server";
      description = ''
        K3s node role:
        - "bootstrap": First node that initializes the cluster with embedded etcd
        - "server": Subsequent node that joins the existing cluster
      '';
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the K3s cluster token file";
    };

    bootstrapAddress = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.50";
      description = "IP address of the bootstrap node for joining nodes to connect to";
    };
  };

  config = lib.mkIf cfg.enable {
    services.k3s = {
      enable = true;
      role = "server";
      clusterInit = cfg.role == "bootstrap";
      serverAddr = lib.mkIf (cfg.role != "bootstrap") "https://${cfg.bootstrapAddress}:6443";
      extraFlags = toString ([
        "--token-file" cfg.tokenFile
        "--disable" "traefik"
      ] ++ lib.optionals (cfg.role == "bootstrap") [
        "--tls-san" cfg.bootstrapAddress
      ]);
    };

    networking.firewall = {
      allowedTCPPorts = [
        6443   # Kubernetes API server
        2379   # etcd clients (embedded etcd)
        2380   # etcd peers (embedded etcd)
        10250  # Kubelet metrics
      ];
      allowedUDPPorts = [
        8472   # Flannel VXLAN overlay network
      ];
    };
  };
}
