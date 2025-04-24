{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

			./../shared/locale.nix
			./../shared/networking.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages-rt_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

	# Configure hostname	
	networking.hostName = "E01";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  users.users.marcel = {
    isNormalUser = true;
    description = "marcel";
    extraGroups = [ "networkmanager" "wheel" ];
  };

	security.sudo.extraConfig = ''
		Defaults                timestamp_timeout=30
		Defaults                passwd_tries=3
		Defaults                insults
	'';

	environment.systemPackages = with pkgs; [
		neovim
		wget
		btop
		tree
		killall
		git

		rustup
		cargo
		mold # Drop in replacement for LLVM lld linkers
		gcc
		clang
		cmake

		# SMT Solvers
		bitwuzla
		cvc5
		yices
		z3
		boolector
		stp
	];

	environment.variables = {
		RUSTFLAGS = "-C link-arg=-fuse-ld=mold";
		CARGO_BUILD_TARGET = "x86_64-unknown-linux-gnu";
	};

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  services.openssh = {
    enable = true;
  };

	# DO NOT CHANGE STATE WITHOUT READING DOCS!
  system.stateVersion = "24.11";
}

