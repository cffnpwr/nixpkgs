{ config, lib, ... }:

with lib;

let
  cfg = config.programs.claude-code;

in
{
  options.programs.claude-code = {
    agents = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = ''
        Attribute set of custom sub-agent files to deploy under ~/.claude/agents/.
        Keys are the filenames (e.g., "prompt-evaluator.md"),
        values are the source paths.
      '';
      example = literalExpression ''
        {
          "prompt-evaluator.md" = ./agents/prompt-evaluator.md;
          "git-commit-planner.md" = ./agents/git-commit-planner.md;
          "git-commit-executor.md" = ./agents/git-commit-executor.md;
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    home.file = mapAttrs' (
      filename: source: nameValuePair ".claude/agents/${filename}" { inherit source; }
    ) cfg.agents;
  };
}
