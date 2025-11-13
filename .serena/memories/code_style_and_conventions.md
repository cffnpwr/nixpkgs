# Code Style and Conventions

## Formatting
- **Formatter**: nixfmt-rfc-style (RFC 166 style)
- **EditorConfig**: Present at `.editorconfig`
  - Indentation: 2 spaces
  - Charset: utf-8
  - End of line: lf
  - Trim trailing whitespace: true
  - Insert final newline: true

## Nix Code Conventions

### Module Structure
Modules follow standard NixOS/Home Manager patterns:
```nix
{ config, lib, pkgs, internalLib, ... }:

let
  cfg = config.<namespace>.<module-name>;
in
{
  options.<namespace>.<module-name> = {
    enable = lib.mkEnableOption "<description>";
    
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.<package-name>;
      defaultText = lib.literalExpression "pkgs.<package-name>";
      description = "The package to use.";
    };
    
    # Additional options...
  };

  config = lib.mkIf cfg.enable {
    # Implementation...
  };
}
```

### Naming Conventions
- **Options**: camelCase (e.g., `enable`, `extraArgs`, `defaultValue`)
- **Variables**: camelCase (e.g., `cfg`, `helpers`, `mkConfigFile`)
- **Files**: kebab-case (e.g., `karabiner-dk`, `google-japanese-ime`)
- **Functions**: camelCase (e.g., `mkHelpers`, `mkConfigFile`)

### Option Types
Use appropriate option types:
- `lib.types.bool` for boolean flags
- `lib.types.package` for packages
- `lib.types.str` for strings
- `lib.types.lines` for multi-line strings
- `lib.types.attrsOf` for attribute sets
- `lib.types.listOf` for lists
- `lib.types.submodule` for nested options

### Internal Library Usage
This project uses `internalLib` for shared functionality:
```nix
{ config, lib, pkgs, internalLib, ... }:

let
  helpers = internalLib.<module-name>.mkHelpers pkgs;
in
```

## Documentation
- Use `description` field for all options
- Include `example` for complex options
- Use `defaultText` for dynamic defaults
- Add comments for non-obvious logic

## Platform Support
- Support multiple platforms: x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin
- Use platform checks: `pkgs.stdenv.isDarwin`, `pkgs.stdenv.isLinux`
- Provide platform-specific implementations using `lib.mkMerge`

## Module Organization
- **programs.X**: Configuration for user programs (package + config files)
- **services.X**: Long-running daemons/agents (systemd/launchd services)
- Split complex modules into multiple files (options, config, helpers)
