{
  pkgs,
  lib,
  flake,
}:
let
  systemToRunner = {
    "x86_64-linux" = "ubuntu-24.04";
    "aarch64-linux" = "ubuntu-24.04-arm";
    "x86_64-darwin" = "macos-15-intel";
    "aarch64-darwin" = "macos-15";
  };

  # collect packages recursively from attrset
  collectPackagesRecursive =
    system: prefix: attrset:
    lib.flatten (
      lib.mapAttrsToList (
        name: value:
        let
          fullName = if prefix == "" then name else "${prefix}.${name}";
        in
        # check if value is a derivation
        if lib.isDerivation value then
          # Check if package is available on the target system
          if lib.meta.availableOn { inherit system; } value then [ fullName ] else [ ]
        # recurseForDerivations属性を持つ場合は再帰
        else if lib.isAttrs value && (value.recurseForDerivations or false) then
          collectPackagesRecursive system fullName value
        else
          [ ]
      ) attrset
    );

  # collect packages across all systems in flake.legacyPackages
  collectPackages =
    let
      # convert to list of { system, package, os } from legacyPackages
      systemPackages = lib.mapAttrsToList (
        system: packages:
        let
          packageNames = collectPackagesRecursive system "" packages;
        in
        map (name: {
          inherit system;
          package = name;
          os = systemToRunner.${system} or null;
        }) packageNames
      ) flake.legacyPackages;
    in
    # flatten and filter out packages without os
    lib.filter (item: item.os != null) (lib.flatten systemPackages);

  # convert to GitHub Actions matrix format
  matrix = {
    include = collectPackages;
  };

  # convert to JSON
  matrixJson = builtins.toJSON matrix;
in
lib.getExe (
  pkgs.writeShellScriptBin "generate-github-actions-matrix" ''
    echo '${matrixJson}'
  ''
)
