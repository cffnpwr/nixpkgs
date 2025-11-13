{ config, lib, ... }:

with lib;

let
  cfg = config.programs.claude-code;

in
{
  options.programs.claude-code = {
    files = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = ''
        Attribute set of files to deploy under ~/.claude/.
        Keys are the relative paths from ~/.claude/ (e.g., "CLAUDE.md", "instructions/code_quality.md"),
        values are the source paths.
      '';
      example = literalExpression ''
        {
          "CLAUDE.md" = ./CLAUDE.md;
          "instructions/code_quality.md" = ./instructions/code_quality.md;
          "instructions/editor.md" = ./instructions/editor.md;
          "instructions/reminders.md" = ./instructions/reminders.md;
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    home.file = mapAttrs' (
      relativePath: source: nameValuePair ".claude/${relativePath}" { inherit source; }
    ) cfg.files;
  };
}
