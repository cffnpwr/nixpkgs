# Nix package update script
#
# To run: `nix run .#update-pkg <package name>`
# If <package name> is omitted, show all available packages: `nix run .#update-pkg`
#
#
#
# Contains code inspired by:
# https://github.com/NixOS/nixpkgs/blob/master/maintainers/scripts/update.nix

{
  pkgs,
  lib,
  allPackages,
}:
let
  path = lib.makeBinPath [
    pkgs.nix
    pkgs.jq
    pkgs.git
    pkgs.gnused
  ];

  allPkgNames = lib.attrNames allPackages;
  pkgList = lib.filter (v: allPackages.${v} ? passthru.updateScript) allPkgNames;
  availablePkgs = lib.concatMapStringsSep "\n" (pkg: "    echo '  - ${pkg}'") pkgList;

  # Parse updateScript into command list (handles attrset, list, or single derivation)
  parseUpdateScript =
    updateScript:
    if lib.isAttrs updateScript && updateScript ? command then
      lib.toList updateScript.command
    else if lib.isList updateScript then
      updateScript
    else
      [ updateScript ];

  # Convert updateScript to shell command string (following nixpkgs official approach)
  getUpdateScriptCmd =
    pkg:
    let
      updateScript = allPackages.${pkg}.passthru.updateScript;
      cmdList = parseUpdateScript updateScript;
      cmdStrings = map (x: "${x}") cmdList;
    in
    lib.concatStringsSep " " (map lib.escapeShellArg cmdStrings);

  # Extract first element (script) from each updateScript for build dependencies
  updateScriptDerivations = map (
    pkg:
    let
      updateScript = allPackages.${pkg}.passthru.updateScript;
      cmdList = parseUpdateScript updateScript;
    in
    builtins.head cmdList
  ) pkgList;

  # Generate case statement entry for a package
  mkCaseEntry =
    pkg:
    let
      pkgInfo = allPackages.${pkg};
      updateCmd = getUpdateScriptCmd pkg;
    in
    lib.concatStringsSep "\n" [
      "  ${pkg})"
      "    export UPDATE_NIX_NAME=\"${pkgInfo.name}\""
      "    export UPDATE_NIX_PNAME=\"${pkgInfo.pname}\""
      "    export UPDATE_NIX_OLD_VERSION=\"${pkgInfo.version}\""
      "    export UPDATE_NIX_ATTR_PATH=\"${pkg}\""
      ""
      "    _run_update_script ${updateCmd}"
      "    ;;"
    ];

  eachAvailablePkgs = lib.concatMapStringsSep "\n" mkCaseEntry pkgList;

  script = pkgs.writeShellScriptBin "update-pkg" ''
    set -euo pipefail

    PATH=${path}

    # Ensure updateScripts are built (referenced here to force evaluation)
    # ${lib.concatStringsSep " " (map (x: "${x}") updateScriptDerivations)}

    pkg_name="''${1:-}"

    _echo_available_pkgs() {
      echo "Available packages:"
      ${availablePkgs}
    }

    _run_update_script() {
      local cmd_args=("$@")
      local workdir=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

      # Replace /nix/store/<hash>-source/ paths with workdir (following nixpkgs official approach)
      local replaced_args=()
      for arg in "''${cmd_args[@]}"; do
        local replaced
        replaced=$(echo "$arg" | sed -E "s|/nix/store/[^/]+-source/|$workdir/|g")
        replaced_args+=("$replaced")
      done

      echo "Running update script for $UPDATE_NIX_NAME (version: $UPDATE_NIX_OLD_VERSION)..."

      local quoted_cmd=""
      for arg in "''${replaced_args[@]}"; do
        quoted_cmd="$quoted_cmd $(printf '%q' "$arg")"
      done

      cd "$workdir"
      exec nix develop --command bash -c "$quoted_cmd"
    }

    if [ -z "$pkg_name" ]; then
      echo "Usage: nix run .#update-pkg <package-name>"
      _echo_available_pkgs
      exit 1
    fi

    # Check if package exists, has update script and execute update script
    case $pkg_name in
    ${eachAvailablePkgs}
      *)
        echo "Error: Package '$pkg_name' not found or does not have an update script."
        _echo_available_pkgs
        exit 1
        ;;
    esac
  '';
in
lib.getExe script
