# 🐧 My Personal NixOS Configuration ⚙️
	 
This repository contains my personal NixOS configuration files.

> "In the world of NixOS, you don't reinstall your computer - you redefine it."

## 📚 Table of Contents
- [What is Nix?](#-what-is-nix--nixos)
- [How Nix Works](#-how-nix-works)
- [Repository Structure](#-repository-structure)
- [Usage](#-usage)
- [License](#-license)

## 🔧 What is Nix / NixOS?

[NixOS](https://nixos.org/) is a Linux distribution that uses the Nix package manager.<br/>
[Nix](https://github.com/NixOS/nix) is a powerful package manager and system configuration tool.

Nix is:
- Declarative
- Reliable
- Reproducible
- Atomicly Versioned

## 🛠️ How Nix Works

Nix uses a functional approach to package management and system configuration:

1. Packages are built in isolation, meaning no dependencies are shared between them.
2. Each package version has a unique hash, allowing multiple versions of a package to coexist.
3. System configurations are defined in Nix expressions, describing the desired state.
4. Nix builds a new system configuration without affecting the current one.
5. The new configuration can be activated, and easily switched between configurations.

## 📁 Repository Structure

- `configuration.nix`: Main NixOS configuration file
- TBD...

## 🚀 Usage

Feel free to use this as a template, or simply to look and determine how things work.

If you want to use this configuration, or test it:
1. Clone this repository to your NixOS machine.
2. Symlink or copy the configuration files to `/etc/nixos/`.
3. Run `sudo nixos-rebuild switch` to apply the configuration.

## 📄 License

This configuration is released under the Unlicense License. See the [license file](https://github.com/Supermarcel10/NixOSConfig/blob/main/LICENSE) for details.
