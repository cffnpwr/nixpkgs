{ config, lib, ... }:

with lib;

let
  cfg = config.programs.claude-code;

in
{
  options.programs.claude-code = {
    commands = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = ''
        Attribute set of custom slash command files to deploy under ~/.claude/commands/.
        Keys are the relative paths from ~/.claude/commands/ (e.g., "reflection.md", "git/commit.md"),
        values are the source paths.
      '';
      example = literalExpression ''
        {
          "reflection.md" = ./commands/reflection.md;
          "git/commit.md" = ./commands/git/commit.md;
          "git/push.md" = ./commands/git/push.md;
          "git/rebase.md" = ./commands/git/rebase.md;
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    home.file = mapAttrs' (
      relativePath: source: nameValuePair ".claude/commands/${relativePath}" { inherit source; }
    ) cfg.commands;
  };
}
