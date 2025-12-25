let
  flake =
    (import
      (fetchTarball {
        url = "https://github.com/edolstra/flake-compat/archive/35bb57c0c8d8b62bbfd284272c928ceb64ddbde9.tar.gz";
        sha256 = "1prd9b1xx8c0sfwnyzkspplh30m613j42l1k789s521f4kv4c2z2";
      })
      {
        src = ./.;
      }
    ).defaultNix;

  lib = flake.lib or (import <nixpkgs> { }).lib;

  # Fix meta.position to use workspace path instead of store path
  fixMetaPosition =
    pkg:
    if pkg ? meta && pkg.meta ? position then
      let
        # Extract relative path after "-source/" (e.g., /pkgs/fusuma/default.nix:30)
        match = builtins.match "/nix/store/[^/]+-source(/.*)" pkg.meta.position;
        relativePath = if match != null then builtins.head match else null;
        # Construct new path: /path/to/repo + /pkgs/fusuma/default.nix:30
        position = if relativePath != null then (toString ./. + relativePath) else pkg.meta.position;
      in
      pkg
      // {
        meta = pkg.meta // {
          inherit position;
        };
      }
    else
      pkg;

  packages = lib.mapAttrs (_: fixMetaPosition) flake.legacyPackages.${builtins.currentSystem};
in
# Export legacyPackages at top level for compatibility with update scripts
packages
// {
  inherit (flake)
    lib
    nixosModules
    darwinModules
    homeModules
    ;
}
