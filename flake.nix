{
  description = "cffnpwr's personal nixpkgs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    lib-aggregate.url = "github:nix-community/lib-aggregate";
    flake-compat.url = "github:nix-community/flake-compat";
  };

  outputs =
    inputs:
    let
      inherit (inputs.lib-aggregate) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = lib.flake-utils.eachSystem systems;

      internalLib = import ./lib { inherit (inputs.nixpkgs) lib; };

      modulesFromDirWithInternalLib =
        dir:
        lib.mapAttrs (name: module: {
          imports = [ module ];
          config._module.args.internalLib = internalLib.internalLib;
        }) (internalLib.modulesFromDir dir);
    in
    {
      # Overlays
      overlays.default =
        final: prev:
        lib.packagesFromDirectoryRecursive {
          callPackage = final.callPackage;
          directory = ./pkgs;
        }
        // {
          lib = prev.lib.extend (
            _: _: {
              maintainers = (prev.lib.maintainers or { }) // internalLib.maintainers;
            }
          );
        };

      # Home Manager modules
      homeModules = modulesFromDirWithInternalLib ./modules/home-manager;

      # nix-darwin modules
      darwinModules = modulesFromDirWithInternalLib ./modules/darwin;

      # NixOS modules
      nixosModules = modulesFromDirWithInternalLib ./modules/nixos;
    }
    // forAllSystems (
      system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.self.overlays.default ];
          config.allowUnfree = true;
        };

        allPackages = lib.packagesFromDirectoryRecursive {
          callPackage = pkgs.callPackage;
          directory = ./pkgs;
        };
      in
      {
        packages = lib.filterAttrs (_: pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg) allPackages;

        formatter = pkgs.nixfmt-rfc-style;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            git
            nil
            nixd
            nixfmt-rfc-style
          ];
        };
      }
    );
}
