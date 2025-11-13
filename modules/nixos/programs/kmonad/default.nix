{
  config,
  lib,
  pkgs,
  internalLib,
  ...
}:

let
  cfg = config.programs.kmonad;

  kmonadLib = internalLib.programs.kmonad;
  helpers = kmonadLib.mkHelpers pkgs;
  inherit (helpers) mkConfigFile;
in
{
  options.programs.kmonad = kmonadLib.mkKmonadOptions pkgs;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Store generated config files (accessible to kmonad service)
    environment.etc = lib.mapAttrs' (
      name: keyboard:
      lib.nameValuePair "kmonad/${name}.kbd" {
        source = mkConfigFile cfg.package keyboard;
      }
    ) cfg.keyboards;
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
