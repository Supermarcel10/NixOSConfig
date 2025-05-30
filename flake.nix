{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		agenix.url = "github:ryantm/agenix";
	};

	outputs = { self, nixpkgs, nixpkgs-unstable, agenix, ... }: {
		nixosConfigurations = {
			marcel-pc = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./devices/marcel-pc/configuration.nix
					agenix.nixosModules.default
				];

				specialArgs = {
					inherit agenix;
					unstable = import nixpkgs-unstable {
						system = "x86_64-linux";
						config.allowUnfree = true;
					};
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

			E01 = nixpkgs-unstable.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./devices/E01/configuration.nix
				];
			};
		};
	};
}
