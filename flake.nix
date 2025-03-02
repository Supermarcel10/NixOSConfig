{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
    };
  };

  outputs = { self, nixpkgs, agenix }: {
    nixosConfigurations = {
      marcel-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./devices/marcel-pc/configuration.nix
          agenix.nixosModules.default
        ];
        
        specialArgs = {
          inherit agenix;
        };
      };

      marcel-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./devices/marcel-laptop/configuration.nix
          agenix.nixosModules.default
        ];
        
        specialArgs = {
          inherit agenix;
        };
      };
    };
  };
}
