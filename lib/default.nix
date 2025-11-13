{ lib }:
let
  modulesFromDir =
    dir:
    let
      # collect modules recursively
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
          currentModules = builtins.listToAttrs (
            builtins.map (fileAttrs:
              let
                imported = import fileAttrs.path;
              in
              {
                inherit (fileAttrs) name;
                value = if builtins.isFunction imported then imported { inherit lib; } else imported;
              }
            ) moduleAttrs
          );

          # Find subdirectories (excluding those with default.nix)
          subdirs = builtins.filter (
            name:
            let
              fileType = allFiles.${name};
              hasDefaultNix = lib.filesystem.pathIsRegularFile "${currentDir}/${name}/default.nix";
            in
            fileType == "directory" && !hasDefaultNix
          ) (builtins.attrNames allFiles);
          subdirModules = builtins.map (subdir: collectModules "${currentDir}/${subdir}") subdirs;

          # Merge all modules
          allModules = builtins.foldl' (acc: modules: acc // modules) currentModules subdirModules;
        in
        allModules;
    in
    collectModules dir;

  internalLib = modulesFromDir ./.;
in
{
  inherit modulesFromDir internalLib;
}
