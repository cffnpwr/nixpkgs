{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.claude-code;

  jsonFormat = pkgs.formats.json { };

  hookType = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [ "command" ];
        description = "Hook type (currently only 'command' is supported)";
      };

      command = mkOption {
        type = types.str;
        description = "Shell command to execute";
      };
    };
  };

  hookMatcherType = types.submodule {
    options = {
      matcher = mkOption {
        type = types.str;
        default = "";
        description = ''
          Pattern to match for triggering the hook.
          Can be specific tool names (e.g., "Bash"), patterns (e.g., "Edit|MultiEdit|Write"),
          or "*" for all tools.
        '';
      };

      hooks = mkOption {
        type = types.listOf hookType;
        default = [ ];
        description = "List of hooks to execute when the matcher is triggered";
      };
    };
  };

  # Available hook events based on documentation
  hookEventType = types.enum [
    "PreToolUse"
    "PostToolUse"
    "UserPromptSubmit"
    "Notification"
    "Stop"
    "SubagentStop"
    "PreCompact"
    "SessionStart"
    "SessionEnd"
  ];

  statusLineType = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [ "command" ];
        description = "Status line type";
      };

      command = mkOption {
        type = types.str;
        description = "Command to generate status line content";
      };
    };
  };

in
{
  options.programs.claude-code = {
    settings = mkOption {
      type = types.submodule {
        options = {
          apiKeyHelper = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Custom script to generate authentication value";
            example = "/bin/generate_temp_api_key.sh";
          };

          cleanupPeriodDays = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Days to retain local chat transcripts (default: 30)";
            example = 30;
          };

          env = mkOption {
            type = types.attrsOf (
              types.oneOf [
                types.bool
                types.str
                types.int
              ]
            );
            default = { };
            description = "Environment variables applied to every session";
            example = literalExpression ''
              {
                CLAUDE_CODE_ENABLE_TELEMETRY = false;
                DISABLE_AUTOUPDATER = true;
              }
            '';
          };

          includeCoAuthoredBy = mkOption {
            type = types.bool;
            default = false;
            description = "Include 'co-authored-by Claude' in git commits";
          };

          permissions = {
            allow = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Permitted tool and command rules";
              example = literalExpression ''
                [
                  "Read(**/*)"
                  "Edit(**/*)"
                  "Bash(git:*)"
                  "mcp__github__*"
                ]
              '';
            };

            ask = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Rules requiring user confirmation before execution";
            };

            deny = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Prohibited tool and command rules";
            };

            additionalDirectories = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Additional accessible working directories";
            };

            defaultMode = mkOption {
              type = types.nullOr (
                types.enum [
                  "allow"
                  "ask"
                  "deny"
                ]
              );
              default = null;
              description = "Default permission mode for unmatched rules";
            };
          };

          hooks = mkOption {
            type = types.attrsOf (types.listOf hookMatcherType);
            default = { };
            description = ''
              Custom commands to run at specific hook events.
              Keys must be valid hook event names: PreToolUse, PostToolUse, UserPromptSubmit,
              Notification, Stop, SubagentStop, PreCompact, SessionStart, SessionEnd.
            '';
            example = literalExpression ''
              {
                Notification = [{
                  matcher = "";
                  hooks = [{
                    type = "command";
                    command = "notify-send 'Claude Code' 'Permission requested'";
                  }];
                }];
                Stop = [{
                  matcher = "";
                  hooks = [{
                    type = "command";
                    command = "notify-send 'Claude Code' 'Task completed'";
                  }];
                }];
              }
            '';
          };

          disableAllHooks = mkOption {
            type = types.bool;
            default = false;
            description = "Disable all hooks globally";
          };

          model = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Override default Claude model";
            example = "claude-sonnet-4-5-20250929";
          };

          statusLine = mkOption {
            type = types.nullOr statusLineType;
            default = null;
            description = "Custom status line configuration";
            example = literalExpression ''
              {
                type = "command";
                command = "mise x -- ccusage statusline";
              }
            '';
          };
        };
      };
      default = { };
      description = "Claude Code settings configuration";
    };
  };

  config = mkIf cfg.enable {
    home.file.".claude/settings.json" =
      let
        settings = filterAttrs (_: v: v != null && v != [ ] && v != { }) {
          apiKeyHelper = cfg.settings.apiKeyHelper;
          cleanupPeriodDays = cfg.settings.cleanupPeriodDays;
          env = cfg.settings.env;
          includeCoAuthoredBy = cfg.settings.includeCoAuthoredBy;
          permissions = filterAttrs (_: v: v != null && v != [ ]) {
            allow = cfg.settings.permissions.allow;
            ask = cfg.settings.permissions.ask;
            deny = cfg.settings.permissions.deny;
            additionalDirectories = cfg.settings.permissions.additionalDirectories;
            defaultMode = cfg.settings.permissions.defaultMode;
          };
          hooks = cfg.settings.hooks;
          disableAllHooks = cfg.settings.disableAllHooks;
          model = cfg.settings.model;
          statusLine = cfg.settings.statusLine;
        };
      in
      mkIf (settings != { }) {
        source = jsonFormat.generate "claude-settings.json" settings;
      };
  };
}
