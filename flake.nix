{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      agenix,
      ...
    }:
    let
      paths = {
        modules = ./modules;
        hardware = paths.modules + /hardware;
        desktop_environments = paths.modules + /desktop_environments;

        apps = ./apps;
        profiles = ./profiles;

        secrets = ./secrets;
      };

      flameshotOverlay = final: prev: {
        flameshot = prev.flameshot.overrideAttrs (old: {
          src = final.fetchFromGitHub {
            owner = "flameshot-org";
            repo = "flameshot";
            rev = "76d883362fa1872f3e0aa31c179c98ebbd0effff";
            sha256 = "068pp62rn1hig1xzss779rpzlrsx8ic7wk6168z2vpw8h9ma1xyx";
          };
          patches = [];
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.git ];
          postPatch = ''
            mkdir -p external/Qt-Color-Widgets external/KDSingleApplication
            echo 'add_library(qtcolorwidgets INTERFACE)' > external/Qt-Color-Widgets/CMakeLists.txt
            echo 'add_library(kdsingleapplication INTERFACE)' > external/KDSingleApplication/CMakeLists.txt
          '';
        });
      };
      overlays = [ flameshotOverlay ];
    in
    {
      nixosConfigurations = {
        marcel-pc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/marcel-pc/configuration.nix
            agenix.nixosModules.default
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
            ./hosts/marcel-laptop/configuration.nix
            agenix.nixosModules.default
            { nixpkgs.overlays = overlays; }
          ];

          specialArgs = {
            inherit agenix paths;
          };
        };
      };
    };
}
