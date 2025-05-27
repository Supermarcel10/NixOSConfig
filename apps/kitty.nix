{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
  ];

	environment.variables = {
		TERMINAL = "kitty";
	};
}
