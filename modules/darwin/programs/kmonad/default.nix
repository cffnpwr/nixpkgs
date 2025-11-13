{
  config,
  lib,
  pkgs,
  internalLib,
  ...
}:

let
  cfg = config.programs.kmonad;

  helpers = internalLib.kmonad.mkHelpers pkgs;
  inherit (helpers) mkConfigFile;
in
{
  options.programs.kmonad = internalLib.kmonad.mkKmonadOptions pkgs;

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [ cfg.package ];
      etc = lib.mapAttrs' (
        name: keyboard:
        lib.nameValuePair "kmonad/${name}.kbd" {
          source = mkConfigFile cfg.package keyboard;
        }
      ) cfg.keyboards;
    };
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
