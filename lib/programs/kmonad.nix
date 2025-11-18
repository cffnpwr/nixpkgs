{ lib }:
{
  mkHelpers =
    pkgs:
    let
      normalizeDevice =
        keyboard:
        if builtins.isString keyboard.device then
          keyboard.device
        else if pkgs.stdenv.isLinux then
          keyboard.device.linux
        else
          keyboard.device.darwin;

      mkDefcfg =
        keyboard:
        let
          device = normalizeDevice keyboard;
          composeConfig = lib.optionalString (keyboard.defcfg.compose.key != null) ''
            cmp-seq ${keyboard.defcfg.compose.key}
            cmp-seq-delay ${toString keyboard.defcfg.compose.delay}
          '';
          inputOutput =
            if pkgs.stdenv.isLinux then
              ''
                input  (device-file "${device}")
                  output (uinput-sink "kmonad-${keyboard.name}")
              ''
            else
              ''
                input  (iokit-name "${device}")
                  output (kext)
              '';
        in
        ''
          (defcfg
            ${inputOutput}
            ${composeConfig}
            fallthrough ${lib.boolToString keyboard.defcfg.fallthrough}
            allow-cmd ${lib.boolToString keyboard.defcfg.allowCommands}
          )
        '';

      mkConfigFile =
        kmonadPackage: keyboard:
        pkgs.writeTextFile {
          name = "kmonad-${keyboard.name}.kbd";
          text = lib.optionalString keyboard.defcfg.enable (mkDefcfg keyboard + "\n") + keyboard.config;
          checkPhase = "${kmonadPackage}/bin/kmonad -d $out";
        };
    in
    {
      inherit normalizeDevice mkDefcfg mkConfigFile;
    };

  mkKeyboardOptions = name: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
        example = "laptop-internal";
        description = "Keyboard name.";
      };

      device = lib.mkOption {
        type = lib.types.either lib.types.str (
          lib.types.submodule {
            options = {
              linux = lib.mkOption {
                type = lib.types.str;
                example = "/dev/input/by-id/usb-keyboard";
                description = "Linux device path";
              };
              darwin = lib.mkOption {
                type = lib.types.str;
                example = "Apple Internal Keyboard / Trackpad";
                description = "macOS IOKit device name";
              };
            };
          }
        );
        example = {
          linux = "/dev/input/by-id/usb-keyboard";
          darwin = "Apple Internal Keyboard / Trackpad";
        };
        description = ''
          Keyboard device specification.
          Can be a string (same for all platforms) or an attribute set with platform-specific values.
        '';
      };

      defcfg = {
        enable = lib.mkEnableOption ''
          automatic generation of the defcfg block.
          When enabled, the config option should not include a defcfg block
        '';

        compose = {
          key = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "ralt";
            description = "Compose key for compose sequences.";
          };

          delay = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 5;
            example = 5;
            description = "Delay in milliseconds between compose sequence events.";
          };
        };

        fallthrough = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to re-emit unhandled key events.";
        };

        allowCommands = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to allow shell commands execution.";
        };

        keySeqDelay = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 1;
          example = 1;
          description = "Delay in milliseconds after each output key event.";
        };
      };

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "--log-level"
          "debug"
        ];
        description = "Extra arguments to pass to KMonad.";
      };

      config = lib.mkOption {
        type = lib.types.lines;
        description = ''
          KMonad keyboard configuration (defsrc, deflayer, etc.).
          This is platform-independent.
        '';
      };
    };
  };

  mkKmonadOptions = pkgs: {
    enable = lib.mkEnableOption "KMonad keyboard remapping";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kmonad;
      defaultText = lib.literalExpression "pkgs.kmonad";
      description = "The KMonad package to use.";
    };

    keyboards = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule ({ name, ... }: (import ./kmonad.nix { inherit lib; }).mkKeyboardOptions name)
      );
      default = { };
      example = lib.literalExpression ''
        {
          "main" = {
            device = {
              linux = "/dev/input/by-id/usb-My_Keyboard";
              darwin = "Apple Internal Keyboard / Trackpad";
            };
            defcfg.enable = true;
            defcfg.compose.key = "ralt";
            defcfg.compose.delay = 5;
            extraArgs = [ "--log-level" "debug" ];
            config = '''
              (defsrc esc 1 2 3)
              (deflayer base caps 1 2 3)
            ''';
          };
        }
      '';
      description = "Keyboard configurations.";
    };
  };
}
