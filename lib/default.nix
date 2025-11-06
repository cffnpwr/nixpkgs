{ lib }:
{
  # KMonad共通ライブラリ
  kmonad = import ./kmonad.nix { inherit lib; };

  # Maintainers情報
  maintainers = import ../maintainers.nix;
}
