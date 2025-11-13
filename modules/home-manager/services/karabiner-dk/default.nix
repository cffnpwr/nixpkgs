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

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    home.packages = [ cfg.package ];

    launchd.agents.karabiner-virtualhiddevice-daemon = {
      enable = true;
      config = {
        ProgramArguments = [
          "${cfg.package}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
        ];
        Label = "org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon";
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
      };
    };

    home.activation.karabinerDkSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      helpers.mkActivationScript
    );
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
