{ lib }:
let
  optionsDef = import ./options.nix { inherit lib; };
in
{
  mkHelpers =
    pkgs:
    let
      converter = import ./converter.nix { inherit lib pkgs; };
      mozcProto = import ./mozc-proto.nix { inherit lib pkgs; };
    in
    {
      # Create binary configuration file from settings
      mkConfigBinary =
        mozcVersion: settings:
        let
          # Convert GUI settings to Protobuf format
          protobufConfig = converter.toProtobufConfig mozcVersion settings;

          # Convert to textproto format
          configTextProto = pkgs.writeText "google-ime-config.textproto" (
            converter.toTextProto protobufConfig
          );
        in
        pkgs.runCommand "google-ime-config1.db"
          {
            nativeBuildInputs = [ pkgs.protobuf ];
          }
          ''
            ${lib.getExe pkgs.protobuf} \
              --proto_path="${mozcProto}/share/mozc" \
              --encode=mozc.config.Config \
              "${mozcProto}/share/mozc/config.proto" \
              < "${configTextProto}" \
              > "$out"
          '';
    };

  mkGoogleJapaneseIMEOptions = pkgs: {
    enable = lib.mkEnableOption "Google Japanese IME configuration";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.google-japanese-ime;
      defaultText = lib.literalExpression "pkgs.google-japanese-ime";
      description = "The Google Japanese IME package to use.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule optionsDef.options;
      description = ''
        Google Japanese IME configuration using GUI-like structure.
        All settings are organized according to the GUI settings panel.
      '';
    };
  };
}
