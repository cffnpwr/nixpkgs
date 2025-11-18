{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.karabiner-dk;

  targetDir = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications";
  appName = "Karabiner-VirtualHIDDevice-Daemon.app";
  targetAppPath = targetDir + "/" + appName;

  # Use the app from /Applications/Nix Apps for System Extension activation
  nixAppsPath = "/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app";

  activationScript = ''
    echo "Setting up Karabiner-DriverKit-VirtualHIDDevice..."

    # Check if target exists
    if [ -e "${targetAppPath}" ]; then
      # Remove it, if it is a symlink and link destination starts with `/nix/store/`.
      if [ -L "${targetAppPath}" ] && [[ "$(readlink "${targetAppPath}")" == /nix/store/* ]]; then
        rm -rf "${targetAppPath}"
      # Otherwise, fail with error.
      else
        echo "ERROR: ${targetAppPath} already exists and is not a symlink or link destination in the nix store." >&2
        echo "Please remove it manually before activating karabiner-dk service." >&2
        exit 1
      fi
    fi

    # Create parent directory
    mkdir -p "${targetDir}"

    # Create symlink
    ln -nfs \
      "${cfg.package}/${targetAppPath}" \
      "${targetAppPath}"

    echo "Karabiner-DriverKit-VirtualHIDDevice symlink created"

    # Activate the VirtualHIDDevice Manager using the app from /Applications/Nix Apps
    # This is required because macOS System Extensions must be in /Applications
    echo "Activating Karabiner DriverKit..."
    "${nixAppsPath}/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
  '';
in
{
  options.services.karabiner-dk = {
    enable = lib.mkEnableOption "Karabiner-DriverKit-VirtualHIDDevice";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.karabiner-dk;
      defaultText = lib.literalExpression "pkgs.karabiner-dk";
      description = "The Karabiner-DriverKit package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    launchd.daemons.karabiner-virtualhiddevice-daemon = {
      script = ''
        exec "${cfg.package}/${targetAppPath}/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      '';
      serviceConfig = {
        Label = "org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon";
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
      };
    };

    system.activationScripts.postActivation.text = activationScript;
  };

  meta.maintainers = with lib.maintainers; [ cffnpwr ];
}
