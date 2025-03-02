{ config, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		# JetBrains IDEs
		jetbrains.webstorm
		jetbrains.rust-rover
		jetbrains.rider
		jetbrains.pycharm-professional
		jetbrains.idea-ultimate
		jetbrains.clion

		# Development Tools & Programming Languages
		git
		docker
		docker-client
		openjdk21
		python311
		rustup
		cargo
		mold # Drop in replacement for LLVM lld linkers
		gcc
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

		CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "${pkgs.mold}/bin/mold";
		RUSTFLAGS = "-C linker=clang -C link-arg=-fuse-ld=mold";
		CARGO_BUILD_TARGET = "x86_64-unknown-linux-gnu";
	};

	programs.java = {
		enable = true;
		package = pkgs.openjdk21;
	};
}
