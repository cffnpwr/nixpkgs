lib:
{ config, ... }:
{
  options = {
    type = lib.mkOption {
      type = lib.types.enum [
        "http"
        "stdio"
      ];
      description = "Type of MCP server connection";
      example = "stdio";
    };

    url = lib.mkOption {
      type = lib.types.str;
      description = "URL where the MCP server is hosted (HTTP type only)";
      default = "";
      example = "https://api.githubcopilot.com/mcp/";
    };

    command = lib.mkOption {
      type = lib.types.str;
      description = "Command to start the MCP server (stdio type only)";
      default = "";
      example = "mise";
    };

    args = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Arguments to pass to the command";
      default = [ ];
      example = [
        "x"
        "--"
        "mcp-server-git"
      ];
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Environment variables for the MCP server";
      default = { };
      example = {
        PYTHONPATH = "";
      };
    };

    headers = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Headers for HTTP requests (HTTP type only)";
      default = { };
      example = {
        Authorization = "Bearer token";
      };
    };
  };
}
