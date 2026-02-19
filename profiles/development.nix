{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		# JetBrains IDEs
		jetbrains.webstorm
		jetbrains.rust-rover
		jetbrains.rider
		jetbrains.pycharm
		jetbrains.idea
		jetbrains.clion

		# Zed IDE
		zed-editor

		# Development Tools & Programming Languages
		git
		gh
		docker
		docker-client
		openjdk21
		python311
		rustup
		cargo
		mold # Drop in replacement for LLVM lld linkers
		gcc
		nil # LSP for Nix
		nixd # LSP for Nix
		clang
		cmake
		dotnet-sdk
		nodejs
		yarn
		pnpm
		nodejs_22
	];

	environment.variables = {
		PYTHON = "${pkgs.python311}/bin/python";
		RUSTFLAGS = "-C link-arg=-fuse-ld=mold";
		CARGO_BUILD_TARGET = "x86_64-unknown-linux-gnu";
	};

	programs.java = {
		enable = true;
		package = pkgs.openjdk21;
	};
}
