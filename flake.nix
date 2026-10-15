{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
    };
    secrets = {
      url = "git+file:./secrets";
      flake = false;
    };
    skills = {
      url = "git+file:./skills";
      flake = false;
    };
    agenix.url = "github:ryantm/agenix";
    dzgui-flake.url = "github:jiriks74/dzgui.flake";
    lightcraft.url = "github:storytold/lightcraft/v0.8.0";
    lightcraft.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # Pinned to revision before DXVK 3.0 / Wine-TKG 11.16 which breaks
    # ON1 Photo RAW on RDNA4 (RX 9070 XT) with Mesa 26.1.x.
    nix-gaming.url = "github:fufexan/nix-gaming/0c680d0426cf04641f718d083bd352e20bc3e0dc";
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-raspberrypi,
      secrets,
      skills,
      agenix,
      dzgui-flake,
      nix-gaming,
      ...
    }@inputs:
    let
      paths = {
        hosts = ./hosts;
        modules = ./modules;
        hardware = paths.modules + /hardware;
        desktop_environments = paths.modules + /desktop_environments;

        apps = ./apps;
        profiles = ./profiles;

        secrets = secrets;
        skills = skills;
      };

      rpiNodes = import (paths.hosts + /rpi5/nodes.nix);
      baseRpiIpOffset = 50;

      overlays = [];

      rpiConfigurations = builtins.foldl' (acc: name: let
        index = builtins.length (builtins.attrNames acc);
        ip4 = "192.168.1.${toString (baseRpiIpOffset + index)}";
        ip6 = "fd00::1:0:0:${toString (baseRpiIpOffset + index)}";
        isBootstrap = name == "calisto";
      in acc // {
        ${name} = nixos-raspberrypi.lib.nixosSystem {
          modules = [
            ({ config, ... }: {
              networking.hostName = name;

              networking.interfaces.end0 = {
                ipv4.addresses = [{ address = ip4; prefixLength = 24; }];
                ipv6.addresses = [{ address = ip6; prefixLength = 64; }];
              };
              networking.defaultGateway = {
                address = "192.168.1.1";
                interface = "end0";
              };
              age.secrets.hostKey.file = paths.secrets + "/${name}-host-key.age";
              age.secrets.k3sToken.file = paths.secrets + "/k3s-token.age";

              cluster.k3s = {
                enable = isBootstrap;
                role = if isBootstrap then "bootstrap" else "server";
                tokenFile = config.age.secrets.k3sToken.path;
              };
            })
            (paths.hosts + /rpi5/configuration.nix)
            agenix.nixosModules.default
          ];
          specialArgs = {
            inherit nixos-raspberrypi paths inputs;
          };
        };
      }) {} rpiNodes;
    in
    {
      nixosConfigurations = {
        marcel-pc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (paths.hosts + /marcel-pc/configuration.nix)
            agenix.nixosModules.default
            (paths.apps + /lightcraft.nix)
            { lightcraft.enable = true; }
            (
              { pkgs, ... }:
              {
                environment.systemPackages = [
                  dzgui-flake.packages.${pkgs.stdenv.hostPlatform.system}.dzgui
                ];
              }
            )
            { nixpkgs.overlays = overlays; }
          ];

          specialArgs = {
            inherit paths inputs;
            unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
        };

        marcel-laptop = nixpkgs.lib.nixosSystem {
          modules = [
            (paths.hosts + /marcel-laptop/configuration.nix)
            agenix.nixosModules.default
            { nixpkgs.overlays = overlays; }
          ];

          specialArgs = {
            inherit paths inputs;
            unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
        };
      } // rpiConfigurations;
    };
}
