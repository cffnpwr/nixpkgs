{
  config,
  lib,
  pkgs,
  internalLib,
  ...
}:

let
  cfg = config.programs.google-japanese-ime;

  mozcVersion = cfg.package.version;

  helpers = internalLib.google-japanese-ime.mkHelpers pkgs;
  configBinary = helpers.mkConfigBinary mozcVersion cfg.settings;

  configDir =
    if pkgs.stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/Google/JapaneseInput/"
    else
      "${config.xdg.configHome}/mozc/";
in
{
  options.programs.google-japanese-ime = internalLib.google-japanese-ime.mkGoogleJapaneseIMEOptions pkgs;

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals pkgs.stdenv.isDarwin [ cfg.package ];

    # Activation script to deploy Google Japanese IME configuration
    home.activation.googleJapaneseIME = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Deploy user configuration
      $VERBOSE_ECHO "Deploying Google Japanese IME configuration..."
      $DRY_RUN_CMD mkdir -p "${configDir}"
      $DRY_RUN_CMD cp "${configBinary}" "${configDir}/config1.db"

      $VERBOSE_ECHO "✓ Google Japanese IME configuration deployed"
    '';
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
