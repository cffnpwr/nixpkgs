{
  pkgs,
  prev ? pkgs,
  ...
}:
{
  claude-desktop = pkgs.callPackage ./claude-desktop { };
  fusuma = pkgs.callPackage ./fusuma { };
  google-japanese-ime = pkgs.callPackage ./google-japanese-ime { };
  kmonad = pkgs.callPackage ./kmonad { };
  microsoft-office = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./microsoft-office { });
  obsidian = pkgs.callPackage ./obsidian { };
  spotify = pkgs.callPackage ./spotify { spotify = prev.spotify; };
  teams = pkgs.callPackage ./teams { };
}
