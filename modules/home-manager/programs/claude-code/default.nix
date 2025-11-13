{ lib, ... }:
{
  imports = [
    ./files.nix
    ./commands.nix
    ./agents.nix
    ./settings.nix
    ./mcp.nix
  ];

  options.programs.claude-code = {
    enable = lib.mkEnableOption "Claude Code global configuration";
  };

  meta.maintainers = with lib.maintainers; [
    cffnpwr
  ];
}
