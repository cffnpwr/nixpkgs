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

  # systemd user service for Linux
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

  # LaunchAgent for macOS
  mkLaunchAgent =
    name: keyboard:
    let
      configFile = mkConfigFile programCfg.package keyboard;
      args = [ "${configFile}" ] ++ keyboard.extraArgs;
    in
    {
      enable = true;
      config = {
        ProgramArguments = [ "${programCfg.package}/bin/kmonad" ] ++ args;
        RunAtLoad = true;
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/kmonad-${name}.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/kmonad-${name}.error.log";
      };
    };
in
{
  options.services.kmonad = {
    enable = lib.mkEnableOption "KMonad keyboard remapping service";
  };

  config = lib.mkMerge [
    # Common assertions
    (lib.mkIf cfg.enable {
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
    })

    # macOS: LaunchAgent
    (lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
      launchd.agents = lib.mapAttrs' (
        name: keyboard: lib.nameValuePair "kmonad-${name}" (mkLaunchAgent name keyboard)
      ) programCfg.keyboards;

      warnings = [
        ''
          ⚠️  KMonad on macOS requires Input Monitoring permission:

          System Settings > Privacy & Security > Input Monitoring
          → Add and enable: ${programCfg.package}/bin/kmonad

          Note: Home Manager LaunchAgent runs at user-level.
          For system-wide setup with root privileges, use the Darwin system module:

            programs.kmonad = {
              enable = true;
              keyboards.main = {
                device = "Apple Internal Keyboard / Trackpad";
                defcfg.enable = true;
                config = "...";
              };
            };

            services.kmonad.enable = true;
        ''
      ];
    })

    # Linux: systemd user service
    (lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
      systemd.user.services = lib.mapAttrs' (
        name: keyboard: lib.nameValuePair "kmonad-${name}" (mkUserService name keyboard)
      ) programCfg.keyboards;

      warnings = [
        ''
          services.kmonad in Home Manager uses systemd user services.
          You must add your user to the 'input' and 'uinput' groups:

            users.users.<your-username>.extraGroups = ["input" "uinput"];

          For system-wide setup with better performance (Nice -20), use the NixOS system module:

            programs.kmonad = {
              enable = true;
              keyboards.main = {
                device = "/dev/input/by-id/usb-My_Keyboard";
                defcfg.enable = true;
                config = "...";
              };
            };

            services.kmonad.enable = true;

            users.users.<your-username>.extraGroups = ["input"];
        ''
      ];
    })
  ];

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
