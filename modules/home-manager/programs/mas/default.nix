{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.mas;
in
{
  options.programs.mas = {
    enable = lib.mkEnableOption "mas (Mac App Store CLI)";

    apps = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      example = {
        "Amphetamine" = 937984704;
        "Bitwarden" = 1352778147;
      };
      description = ''
        Mac App Store applications to install.
        The attribute name is the app name, and the value is the App Store ID.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = pkgs.stdenv.isDarwin;
          message = "programs.mas is only available on macOS (Darwin).";
        }
      ];
    })

    (lib.mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
      home = {
        packages = [ pkgs.mas ];

        activation.installMasApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # Install each app (mas will handle authentication automatically)
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: id: ''
              if ! ${pkgs.mas}/bin/mas list | grep -q "^${toString id}"; then
                $DRY_RUN_CMD echo "Installing ${name} (${toString id})..."
                $DRY_RUN_CMD ${pkgs.mas}/bin/mas install ${toString id} || echo "Failed to install ${name}. Make sure you're signed into the Mac App Store."
              else
                $DRY_RUN_CMD echo "${name} is already installed"
              fi
            '') cfg.apps
          )}
        '';
      };
    })
  ];

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
