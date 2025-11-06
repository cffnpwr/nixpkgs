{ lib }:
{
  modulesFromDir =
    dir:
    let
      # 再帰的にモジュールを収集する関数
      collectModules =
        currentDir:
        let
          allFiles = builtins.readDir currentDir;

          # .nixファイル（default.nix除く）とdefault.nixを持つディレクトリを取得
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

          # ファイル/ディレクトリをモジュール属性に変換
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

          # 現在のディレクトリのモジュール
          currentModules = builtins.listToAttrs (
            builtins.map (fileAttrs: {
              inherit (fileAttrs) name;
              value = import fileAttrs.path;
            }) moduleAttrs
          );

          # サブディレクトリ（default.nixを持たないもの）を取得
          subdirs = builtins.filter (
            name:
            let
              fileType = allFiles.${name};
              hasDefaultNix = lib.filesystem.pathIsRegularFile "${currentDir}/${name}/default.nix";
            in
            fileType == "directory" && !hasDefaultNix
          ) (builtins.attrNames allFiles);

          # サブディレクトリから再帰的にモジュールを収集
          subdirModules = builtins.map (subdir: collectModules "${currentDir}/${subdir}") subdirs;

          # 全てをマージ
          allModules = builtins.foldl' (acc: modules: acc // modules) currentModules subdirModules;
        in
        allModules;
    in
    collectModules dir;
}
