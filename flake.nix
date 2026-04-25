{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
    };
    secrets = {
      url = "git+file:./secrets";
      flake = false;
    };
    agenix.url = "github:ryantm/agenix";
    dzgui-flake.url = "github:jiriks74/dzgui.flake";
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      nixos-raspberrypi,
      secrets,
      agenix,
      dzgui-flake,
      ...
    }:
    let
      paths = {
        hosts = ./hosts;
        modules = ./modules;
        hardware = paths.modules + /hardware;
        desktop_environments = paths.modules + /desktop_environments;

        apps = ./apps;
        profiles = ./profiles;

        secrets = secrets;
      };

      rpiNodes = import (paths.hosts + /rpi5/nodes.nix);
      baseRpiIpOffset = 50;

      flameshotOverlay = final: prev: {
        flameshot = prev.flameshot.overrideAttrs (old: {
          src = final.fetchFromGitHub {
            owner = "flameshot-org";
            repo = "flameshot";
            rev = "76d883362fa1872f3e0aa31c179c98ebbd0effff";
            sha256 = "068pp62rn1hig1xzss779rpzlrsx8ic7wk6168z2vpw8h9ma1xyx";
          };
          patches = [ ];
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.git ];
          postPatch = ''
            mkdir -p external/Qt-Color-Widgets external/KDSingleApplication
            echo 'add_library(qtcolorwidgets INTERFACE)' > external/Qt-Color-Widgets/CMakeLists.txt
            echo 'add_library(kdsingleapplication INTERFACE)' > external/KDSingleApplication/CMakeLists.txt
          '';
        });
      };

      overlays = [
        flameshotOverlay
      ];

      rpiConfigurations = builtins.foldl' (acc: name: let
        index = builtins.length acc;
        ip4 = "192.168.1.${toString (baseRpiIpOffset + index)}";
        ip6 = "fd00::1:0:0:${toString (baseRpiIpOffset + index)}";
      in acc // {
        ${name} = nixos-raspberrypi.lib.nixosSystem {
          modules = [
            ({ ... }: {
              networking.hostName = name;

              networking.interfaces.end0 = {
                ipv4.addresses = [{ address = ip4; prefixLength = 24; }];
                ipv6.addresses = [{ address = ip6; prefixLength = 64; }];
              };
              age.secrets.hostKey.file = paths.secrets + "/${name}-host-key.age";
            })
            (paths.hosts + /rpi5/configuration.nix)
            agenix.nixosModules.default
          ];
          specialArgs = {
            inherit nixos-raspberrypi paths agenix;
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
            (
              { pkgs, ... }:
              {
                environment.systemPackages = [
                  dzgui-flake.packages.${pkgs.system}.dzgui
                ];
              }
            )
            { nixpkgs.overlays = overlays; }
          ];

          specialArgs = {
            inherit agenix paths;
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
            inherit agenix paths;
          };
        };
      } // rpiConfigurations;
    };
}
