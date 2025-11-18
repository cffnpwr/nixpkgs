{
  config,
  lib,
  pkgs,
  internalLib,
  ...
}:

let
  cfg = config.services.kmonad;
  programCfg = config.programs.kmonad;

  kmonadLib = internalLib.programs.kmonad;
  helpers = kmonadLib.mkHelpers pkgs;
  inherit (helpers) normalizeDevice mkConfigFile;

  mkUserService =
    name: keyboard:
    let
      configFile = mkConfigFile programCfg.package keyboard;
      cmd = [
        "${programCfg.package}/bin/kmonad"
        "${configFile}"
      ]
      ++ keyboard.extraArgs;
    in
    {
      Unit = {
        Description = "KMonad keyboard remapping for ${name}";
        After = [ "graphical-session.target" ];
        ConditionPathExists = normalizeDevice keyboard;
      };

      Service = {
        Type = "simple";
        ExecStart = lib.escapeShellArgs cmd;
        Restart = "always";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
in
{
  options.services.kmonad = {
    enable = lib.mkEnableOption "KMonad keyboard remapping service";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux;
        message = "services.kmonad is only supported on Linux. For macOS, use nix-darwin system module instead.";
      }
      {
        assertion = programCfg.enable;
        message = "services.kmonad requires programs.kmonad.enable = true";
      }
      {
        assertion = programCfg.keyboards != { };
        message = "services.kmonad requires at least one keyboard to be configured in programs.kmonad.keyboards";
      }
    ];

    systemd.user.services = lib.mapAttrs' (
      name: keyboard: lib.nameValuePair "kmonad-${name}" (mkUserService name keyboard)
    ) programCfg.keyboards;

    warnings = lib.optional cfg.enable ''
      KMonad requires user to be in 'input' and 'uinput' groups. Add to configuration: users.users.<username>.extraGroups = ["input" "uinput"];
    '';
  };

  meta.maintainers = with lib.maintainers; [ cffnpwr ];
}
