{
  config,
  lib,
  ...
}:

let
  cfg = config.services.kmonad;
  programCfg = config.programs.kmonad;

  mkLaunchDaemon =
    name: keyboard:
    let
      args = [ "/etc/kmonad/${name}.kbd" ] ++ keyboard.extraArgs;
    in
    {
      script = "${programCfg.package}/bin/kmonad ${lib.escapeShellArgs args}";
      serviceConfig = {
        RunAtLoad = true;
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        UserName = "root";
        GroupName = "wheel";
        StandardOutPath = "/var/log/kmonad-${name}.log";
        StandardErrorPath = "/var/log/kmonad-${name}.error.log";
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

    # Automatically enable karabiner-dk for Input Monitoring
    services.karabiner-dk.enable = true;

    launchd.daemons = lib.mapAttrs' (
      name: keyboard: lib.nameValuePair "kmonad-${name}" (mkLaunchDaemon name keyboard)
    ) programCfg.keyboards;
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
