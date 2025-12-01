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

      libExports = import ./lib { inherit (inputs.nixpkgs) lib; };
      internalLib = libExports.internalLib;

      # Helper to wrap modules with internalLib in extraSpecialArgs
      wrapModulesWithInternalLib = dir: {
        _module.args.internalLib = internalLib;
        imports = lib.collect builtins.isString (internalLib.modulePathsFromDir dir);
      };
    in
    {
      # Overlays
      overlays.default =
        final: prev:
        import ./pkgs {
          pkgs = final;
        }
        // {
          lib = prev.lib.extend (
            _: _: {
              maintainers = (prev.lib.maintainers or { }) // internalLib.maintainers;
            }
          );
        };

      # Home Manager modules
      homeModules.default = wrapModulesWithInternalLib ./modules/home-manager;

      # nix-darwin modules
      darwinModules.default = wrapModulesWithInternalLib ./modules/darwin;

      # NixOS modules
      nixosModules.default = wrapModulesWithInternalLib ./modules/nixos;
    }
    // forAllSystems (
      system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.self.overlays.default ];
          config.allowUnfree = true;
        };

        allPackages = import ./pkgs { inherit pkgs; };
      in
      {
        legacyPackages = lib.filterAttrs (
          _: pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
        ) allPackages;

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
