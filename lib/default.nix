{ lib }:
let
  # Generic function to collect files recursively from a directory
  # Parameters:
  #   - fileFilter: function (name, fileType, currentDirStr) -> bool
  #       * name: file or directory name
  #       * fileType: type from builtins.readDir ("regular", "directory", etc.)
  #       * currentDirStr: absolute path to the parent directory as string
  #   - transformer: function (fileAttrs: { name, path }) -> { name, value }
  #       * fileAttrs.name: file name
  #       * fileAttrs.path: absolute path to the file
  #   - shouldRecurseIntoDir: function (name, fileType, currentDirStr) -> bool (optional, default: always recurse)
  #       * name: directory name
  #       * fileType: type from builtins.readDir (always "directory" when called)
  #       * currentDirStr: absolute path to the parent directory as string
  #       * returns: true to recurse into the directory, false to skip it
  #   - dir: directory to search
  collectFilesFromDir =
    {
      fileFilter,
      transformer,
      shouldRecurseIntoDir ? (
        _name: _fileType: _currentDirStr:
        true
      ),
    }:
    dir:
    let
      collectFiles =
        currentDir:
        let
          allFiles = builtins.readDir currentDir;
          currentDirStr = builtins.unsafeDiscardStringContext (toString currentDir);

          # Filter files based on custom filter function
          matchingFiles = builtins.filter (name: fileFilter name allFiles.${name} currentDirStr) (
            builtins.attrNames allFiles
          );

          # Transform matching files
          currentResults = builtins.listToAttrs (
            builtins.map (
              fileName:
              let
                path = "${currentDirStr}/${fileName}";
              in
              transformer {
                name = fileName;
                path = path;
              }
            ) matchingFiles
          );

          # Find subdirectories to recurse into
          subdirs = builtins.filter (
            name:
            let
              fileType = allFiles.${name};
            in
            fileType == "directory" && shouldRecurseIntoDir name fileType currentDirStr
          ) (builtins.attrNames allFiles);

          # Recursively collect from subdirectories
          subdirResults = builtins.listToAttrs (
            builtins.map (subdir: {
              name = subdir;
              value = collectFiles "${currentDir}/${subdir}";
            }) subdirs
          );

          # Merge current results with subdirectory results
          allResults = currentResults // subdirResults;
        in
        allResults;
    in
    collectFiles dir;

  # Common function to collect modules/paths recursively from a directory
  # The transformer function determines how to process each file
  collectFromDir =
    transformer: dir:
    collectFilesFromDir {
      # Filter: .nix files (excluding default.nix) and directories with default.nix
      fileFilter =
        name: fileType: currentDirStr:
        if fileType == "directory" then
          builtins.pathExists "${currentDirStr}/${name}/default.nix"
        else
          # Skip default.nix files
          lib.strings.hasSuffix ".nix" name && name != "default.nix";

      # Recursion: only into directories WITHOUT default.nix
      shouldRecurseIntoDir =
        name: _fileType: currentDirStr:
        !builtins.pathExists "${currentDirStr}/${name}/default.nix";

      # Transform files to paths
      transformer =
        fileAttrs:
        let
          allFiles = builtins.readDir (dirOf fileAttrs.path);
          fileType = allFiles.${fileAttrs.name};
          path = if fileType == "directory" then "${fileAttrs.path}/default.nix" else fileAttrs.path;
        in
        transformer {
          name =
            if fileType == "directory" then fileAttrs.name else lib.strings.removeSuffix ".nix" fileAttrs.name;
          path = path;
        };
    } dir;

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

  # Collect and merge *.test.nix files from a directory recursively
  # Test files are imported and merged into a nested attribute set
  testsFromDir =
    dir:
    collectFilesFromDir {
      # Filter: only *.test.nix files
      fileFilter =
        name: fileType: _currentDirStr:
        fileType == "regular" && lib.strings.hasSuffix ".test.nix" name;

      # Transform: import test file and create attribute
      transformer =
        fileAttrs:
        let
          testName = lib.strings.removeSuffix ".test.nix" fileAttrs.name;
          tests = import fileAttrs.path { inherit lib; };
        in
        {
          name = testName;
          value = tests;
        };

      # Recurse into all subdirectories
      shouldRecurseIntoDir =
        _name: _fileType: _currentDirStr:
        true;
    } dir;

  lib' = modulesFromDir ./.;
  maintainers = lib'.maintainers;
in
{
  internalLib = lib' // {
    inherit
      modulesFromDir
      modulePathsFromDir
      testsFromDir
      maintainers
      ;
  };
}
