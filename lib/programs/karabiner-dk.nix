{ lib }:
{
  mkHelpers = pkgs: config: {
    mkActivationScript =
      let
        pkg = config.services.karabiner-dk.package;

        appName = "Karabiner-VirtualHIDDevice-Daemon.app";
        dkPath = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications";
        targetDir = (if config ? home.homeDirectory then config.home.homeDirectory else "") + dkPath;
        targetAppPath = targetDir + "/" + appName;
      in
      ''
        $DRY_RUN_CMD echo "Setting up Karabiner-DriverKit-VirtualHIDDevice..."

        # Check if target exists
        if [ -e "${targetAppPath}" ]; then
          # Remove it, if it is a symlink and link destination starts with `/nix/store/`.
          if [ -L "${targetAppPath}" ] && [ "$(readlink "${targetAppPath}")" = /nix/store/* ]; then
            $DRY_RUN_CMD rm -rf "${targetAppPath}"
          # Otherwise, fail with error.
          else
            $DRY_RUN_CMD echo "ERROR: ${targetAppPath} already exists and is not a symlink or link destination in the nix store." >&2
            $DRY_RUN_CMD echo "Please remove it manually before activating karabiner-dk service." >&2
            exit 1
          fi
        fi

        # Create parent directory
        $DRY_RUN_CMD mkdir -p "${targetDir}"

        # Create alias
        $DRY_RUN_CMD ln -nfs \
          "${pkg}/${dkPath}/${appName}" \
          "${targetAppPath}"

        $DRY_RUN_CMD echo "Karabiner-DriverKit-VirtualHIDDevice alias created"

        # Activate the VirtualHIDDevice Manager
        $DRY_RUN_CMD echo "Activating Karabiner DriverKit..."
        $DRY_RUN_CMD "${pkg}/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
      '';
  };

  mkKarabinerDkOptions = pkgs: {
    enable = lib.mkEnableOption "Karabiner-DriverKit-VirtualHIDDevice";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.karabiner-dk;
      defaultText = lib.literalExpression "pkgs.karabiner-dk";
      description = "The Karabiner-DriverKit package to use.";
    };
  };
}
