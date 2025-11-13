{
  config,
  lib,
  pkgs,
  internalLib,
  ...
}:

let
  cfg = config.services.karabiner-dk;

  helpers = internalLib.karabiner-dk.mkHelpers pkgs config;
in
{
  options.services.karabiner-dk = internalLib.karabiner-dk.mkKarabinerDkOptions pkgs;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    launchd.daemons.karabiner-virtualhiddevice-daemon = {
      script = ''
        exec "${cfg.package}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      '';
      serviceConfig = {
        Label = "org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon";
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
      };
    };

    system.activationScripts.postActivation.text = helpers.mkActivationScript;
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
