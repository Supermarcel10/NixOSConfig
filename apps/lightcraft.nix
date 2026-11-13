{ config, pkgs, lib, inputs, ... }:

with lib;

let
  lightcraft-pkg = inputs.lightcraft.packages.${pkgs.stdenv.hostPlatform.system}.lightcraft.overrideAttrs (old: {
    doCheck = false;
    cargoBuildFeatures = (old.cargoBuildFeatures or []) ++ [
      "lightcraft/rawnind-model"
      "lightcraft-cli/rawnind-model"
    ];
    # v0.20.0 pins egui_demo_lib, egui_inspection and egui_system_font_provider
    # in [patch.crates-io], but nothing in the workspace depends on them
    # (Cargo.lock records all three as [[patch.unused]]). `cargo vendor`
    # therefore omits them from the vendored sources and the offline build
    # fails with "patch location ... does not contain packages matching ...".
    # Drop the unused entries; dependency resolution is unchanged. The lock
    # edit is mirrored into the vendored copy, which cargoSetupPostPatchHook
    # diffs against the source lock. Revisit on the next version bump.
    postPatch = (old.postPatch or "") + ''
      sed -i '/^egui_demo_lib = { git = /d; /^egui_inspection = { git = /d; /^egui_system_font_provider = { git = /d' Cargo.toml
      for lock in Cargo.lock "$cargoDepsCopy/Cargo.lock"; do
        sed -i '/^\[\[patch\.unused\]\]/,/^$/d' "$lock"
      done
    '';
  });
in
{
  options.lightcraft = {
    enable = mkEnableOption "LightCraft photo editor (upstream flake)";
  };

  config = mkIf config.lightcraft.enable {
    environment.systemPackages = [
      lightcraft-pkg
    ];
  };
}
