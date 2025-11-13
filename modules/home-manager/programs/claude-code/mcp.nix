{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.claude-code;

  mcpServerOptionsType = import ./mcp-server-types.nix lib;

  # MCP設定JSONを生成
  mcpServersJson = pkgs.writeText "mcp-servers.json" (builtins.toJSON cfg.mcp.servers);

in
{
  options.programs.claude-code = {
    mcp = {
      servers = mkOption {
        type = types.attrsOf (types.submodule mcpServerOptionsType);
        default = { };
        description = ''
          MCP server configurations.

          For HTTP servers with authentication, you can use agenix secrets:
          ```nix
          github = {
            type = "http";
            url = "https://api.githubcopilot.com/mcp/";
            headers = {
              Authorization = "Bearer ''${builtins.readFile config.age.secrets.github-token.path}";
            };
          };
          ```
        '';
        example = literalExpression ''
          {
            git = {
              type = "stdio";
              command = "mise";
              args = ["x" "--" "mcp-server-git"];
              env = {};
            };
            github = {
              type = "http";
              url = "https://api.githubcopilot.com/mcp/";
              headers = {
                Authorization = "Bearer ''${builtins.readFile config.age.secrets.github-token.path}";
              };
            };
          }
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.activation.claudeMcpSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $VERBOSE_ECHO "Syncing Claude MCP servers configuration..."

      # ~/.claude.jsonが存在しない場合は作成
      if [ ! -f ~/.claude.json ]; then
        echo '{}' > ~/.claude.json
      fi

      # .mcpServersセクションのみを更新（他のセクションは保持）
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq \
        --slurpfile mcp ${mcpServersJson} \
        '.mcpServers = $mcp[0]' \
        ~/.claude.json > ~/.claude.json.tmp

      $DRY_RUN_CMD mv ~/.claude.json.tmp ~/.claude.json
      $DRY_RUN_CMD chmod 600 ~/.claude.json

      $VERBOSE_ECHO "Claude MCP servers configuration synced"
    '';
  };
}
