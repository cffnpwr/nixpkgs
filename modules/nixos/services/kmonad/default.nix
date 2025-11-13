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

  mkService =
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
      description = "KMonad keyboard remapping for ${name}";
      wantedBy = [ "multi-user.target" ];

      unitConfig = {
        ConditionPathExists = normalizeDevice keyboard;
      };

      serviceConfig = {
        ExecStart = lib.escapeShellArgs cmd;
        Restart = "always";
        User = "kmonad";
        SupplementaryGroups = [
          "input"
          "uinput"
        ];
        Nice = -20;
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
        assertion = programCfg.enable;
        message = "services.kmonad requires programs.kmonad.enable = true";
      }
      {
        assertion = programCfg.keyboards != { };
        message = "services.kmonad requires at least one keyboard to be configured in programs.kmonad.keyboards";
      }
    ];

    hardware.uinput.enable = true;

    users.groups.uinput = { };
    users.groups.kmonad = { };
    users.users.kmonad = {
      description = "KMonad system user";
      group = "kmonad";
      isSystemUser = true;
      extraGroups = [
        "input"
        "uinput"
      ];
    };

    systemd.services = lib.mapAttrs' (
      name: keyboard: lib.nameValuePair "kmonad-${name}" (mkService name keyboard)
    ) programCfg.keyboards;

    boot.kernelModules = [
      "evdev"
      "uinput"
    ];
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
