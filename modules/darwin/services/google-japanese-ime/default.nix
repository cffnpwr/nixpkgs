# Nix module to manage Google Japanese IME on macOS.
#
# This module is inspired by the following resources:
# - https://github.com/natsukium/dotfiles/blob/main/modules/darwin/google-japanese-input.nix

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.google-japanese-ime;
in
{
  options.services.google-japanese-ime = {
    enable = lib.mkEnableOption "Google Japanese IME Service";

    package = lib.mkPackageOption pkgs "google-japanese-ime" { };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    # FIXME: This is a workaround to avoid the following error
    # GoogleJapaneseInput[xxxx:xxxx] [_IMKServerLegacy _createConnection] could not register com.google.inputmethod.Japanese_Connection
    # GoogleJapaneseInput[xxxx:xxxx] [_IMKServerLegacy initWithName:bundleIdentifier:]: [IMKServer _createConnection]: *Failed* to register NSConnection name=com.google.inputmethod.Japanese_Connection
    # need to remove the packages from `/Library/Input Methods` when disabling the service
    system.activationScripts.extraActivation.text = ''
      OLD="/Library/Input Methods/GoogleJapaneseInput.app"
      NEW="${cfg.package}/Library/Input Methods/GoogleJapaneseInput.app"
      echo copying google-japanese-ime into "$OLD"...
      if [ -d "$OLD" ]; then
        if ! diff -rq "$NEW" "$OLD" &>/dev/null; then
          rm -rf "$OLD"
          cp -R "$NEW" "$OLD"
        fi
      else
        cp -R "$NEW" "$OLD"
      fi
    '';

    environment.userLaunchAgents = {
      "com.google.inputmethod.Japanese.Converter.plist".source =
        "${cfg.package}/Library/LaunchAgents/com.google.inputmethod.Japanese.Converter.plist";
      "com.google.inputmethod.Japanese.Renderer.plist".source =
        "${cfg.package}/Library/LaunchAgents/com.google.inputmethod.Japanese.Renderer.plist";
    };

    system.defaults.inputsources.AppleEnabledThirdPartyInputSources = [
      {
        "Bundle ID" = "com.google.inputmethod.Japanese";
        InputSourceKind = "Keyboard Input Method";
      }
      {
        "Bundle ID" = "com.google.inputmethod.Japanese";
        "Input Mode" = "com.apple.inputmethod.Roman";
        InputSourceKind = "Input Mode";
      }
      {
        "Bundle ID" = "com.google.inputmethod.Japanese";
        "Input Mode" = "com.apple.inputmethod.Japanese";
        InputSourceKind = "Input Mode";
      }
    ];
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
