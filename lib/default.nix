{ lib }:
let
  # Common function to collect modules/paths recursively from a directory
  # The transformer function determines how to process each file
  collectFromDir =
    transformer: dir:
    let
      collectModules =
        currentDir:
        let
          allFiles = builtins.readDir currentDir;

          # retrieve valid entries (nix files and directories with default.nix)
          entries = builtins.filter (
            name:
            let
              fileType = allFiles.${name};
            in
            if fileType == "directory" then
              lib.filesystem.pathIsRegularFile "${currentDir}/${name}/default.nix"
            else
              # Skip default.nix files
              lib.strings.hasSuffix ".nix" name && name != "default.nix"
          ) (builtins.attrNames allFiles);

          moduleAttrs = builtins.map (
            fileName:
            let
              path = "${currentDir}/${fileName}";
            in
            if lib.filesystem.pathIsDirectory path then
              {
                name = fileName;
                path = "${path}/default.nix";
              }
            else
              {
                name = lib.strings.removeSuffix ".nix" fileName;
                path = path;
              }
          ) entries;

          currentModules = builtins.listToAttrs (builtins.map transformer moduleAttrs);

          # Find subdirectories (excluding those with default.nix)
          subdirs = builtins.filter (
            name:
            let
              fileType = allFiles.${name};
              hasDefaultNix = lib.filesystem.pathIsRegularFile "${currentDir}/${name}/default.nix";
            in
            fileType == "directory" && !hasDefaultNix
          ) (builtins.attrNames allFiles);

          subdirModules = builtins.listToAttrs (
            builtins.map (subdir: {
              name = subdir;
              value = collectModules "${currentDir}/${subdir}";
            }) subdirs
          );

          # Merge current modules with subdirectory modules
          allModules = currentModules // subdirModules;
        in
        allModules;
    in
    collectModules dir;

  # Import and evaluate modules from a directory
  modulesFromDir =
    dir:
    collectFromDir (
      fileAttrs:
      let
        imported = import fileAttrs.path;
      in
      {
        inherit (fileAttrs) name;
        value = if builtins.isFunction imported then imported { inherit lib; } else imported;
      }
    ) dir;

  # Get module paths without importing/evaluating them
  # This is used for Nix modules that will be evaluated by the module system
  modulePathsFromDir =
    dir:
    collectFromDir (fileAttrs: {
      inherit (fileAttrs) name;
      value = fileAttrs.path;
    }) dir;

  lib' = modulesFromDir ./.;
  maintainers = lib'.maintainers;
in
{
  inherit
    modulesFromDir
    modulePathsFromDir
    maintainers
    ;
  internalLib = lib';
}
