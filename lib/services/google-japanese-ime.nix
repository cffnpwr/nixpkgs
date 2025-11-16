{ lib }:
{
  mkAgentOptions =
    pkgs:
    let
      imeBasePath = "${pkgs.google-japanese-ime}/Library/Input Methods/GoogleJapaneseInput.app";
    in
    {
      # Prelauncher - Main IME launcher
      "com.google.inputmethod.Japanese.Prelauncher" = {
        enable = true;
        config = {
          ProgramArguments = [
            "${imeBasePath}/Contents/Resources/GoogleJapaneseInputPrelauncher.app/Contents/MacOS/GoogleJapaneseInputPrelauncher"
          ];
          RunAtLoad = true;
          ProcessType = "Interactive";
          LimitLoadToSessionType = "Aqua";
        };
      };

      # Converter - IME conversion engine
      "com.google.inputmethod.Japanese.Converter" = {
        enable = true;
        config = {
          Program = "${imeBasePath}/Contents/Resources/GoogleJapaneseInputConverter.app/Contents/MacOS/GoogleJapaneseInputConverter";
          Label = "com.google.inputmethod.Japanese.Converter";
          MachServices = {
            "com.google.inputmethod.Japanese.Converter.session" = true;
          };
          KeepAlive = false;
        };
      };

      # Renderer - IME UI renderer
      "com.google.inputmethod.Japanese.Renderer" = {
        enable = true;
        config = {
          Program = "${imeBasePath}/Contents/Resources/GoogleJapaneseInputRenderer.app/Contents/MacOS/GoogleJapaneseInputRenderer";
          Label = "com.google.inputmethod.Japanese.Renderer";
          MachServices = {
            "com.google.inputmethod.Japanese.Renderer.renderer" = true;
          };
          KeepAlive = false;
        };
      };
    };
}
