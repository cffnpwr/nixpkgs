{
  config,
  lib,
  pkgs,
  internalLib,
  ...
}:

let
  cfg = config.services.google-japanese-ime;
  googleJpIMEServiceLib = internalLib.services.google-japanese-ime;
in
{
  options.services.google-japanese-ime = {
    enable = lib.mkEnableOption "Google Japanese IME Service";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    launchd.agents = googleJpIMEServiceLib.mkAgentOptions pkgs;
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
