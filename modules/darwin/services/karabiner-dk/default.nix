{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.karabiner-dk;

  targetDir = "/Library/Application\ Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications";
  appName = "Karabiner-VirtualHIDDevice-Daemon.app";
  targetAppPath = targetDir + "/" + appName;

  # Use the app from /Applications/Nix Apps for System Extension activation
  nixAppsPath = "/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app";

  activationScript = ''
    echo "Setting up Karabiner-DriverKit-VirtualHIDDevice..."

    # Get console user (the user logged into GUI)
    CONSOLE_USER=$(stat -f '%Su' /dev/console)
    CONSOLE_UID=$(id -u "$CONSOLE_USER")

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
    # IMPORTANT: Must run in user's GUI session, not as root
    echo "Activating Karabiner DriverKit as user $CONSOLE_USER (UID: $CONSOLE_UID)..."

    # Use launchctl asuser to run in the user's GUI session (Aqua session)
    # This allows the System Extension approval dialog to be displayed
    if ! launchctl asuser "$CONSOLE_UID" sudo -u "$CONSOLE_USER" "${nixAppsPath}/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate; then
      echo "WARNING: Karabiner DriverKit activation failed or requires user approval." >&2
      echo "Please approve the system extension in System Settings > General > Login Items & Extensions > Driver Extensions" >&2
      echo "Continuing with the rest of activation..." >&2
    fi
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
      serviceConfig = {
        Label = "org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon";
        ProgramArguments = [
          "${cfg.package}/${targetAppPath}/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
        UserName = "root";
        GroupName = "wheel";
        StandardOutPath = "/var/log/karabiner-virtualhiddevice-daemon.log";
        StandardErrorPath = "/var/log/karabiner-virtualhiddevice-daemon.error.log";
      };
    };

    system.activationScripts.postActivation.text = activationScript;
  };

  meta.maintainers = with lib.maintainers; [ cffnpwr ];
}
