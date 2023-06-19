{
  description = "cffnpwr's personal nix packages";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    lib-aggregate = { url = "github:nix-community/lib-aggregate"; };
    flake-compat = { url = "github:nix-community/flake-compat"; };
  };

  outputs = inputs:
    let
      inherit (inputs.lib-aggregate) lib;
    in
    lib.flake-utils.eachDefaultSystem (system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
      with pkgs; rec {
        packages = {
          koruri = callPackage ./pkgs/koruri { };
          _0xproto = callPackage ./pkgs/0xproto { };
        };
      }
    );
}
