# Suggested Commands

## Development Environment
```bash
# Enter development shell
nix develop
```

## Code Quality

### Formatting
```bash
# Format all Nix files using nixfmt-rfc-style
nix fmt

# Format specific file
nixfmt <file.nix>
```

### Linting
```bash
# Use nil or nixd for LSP-based linting
# (Configured in editor, no separate command needed)
```

## Building and Testing

### Build packages
```bash
# Build all packages for current system
nix build .#packages.<system>.<package-name>

# Example: Build kmonad for current system
nix build .#kmonad
```

### Check flake
```bash
# Verify flake structure
nix flake check

# Show flake info
nix flake show

# Update inputs
nix flake update
```

## Module Testing

### Test Home Manager modules
```bash
# Build home-manager configuration with this module
nix build .#homeConfigurations.<config>.activationPackage
```

### Test nix-darwin modules
```bash
# Build darwin configuration
nix build .#darwinConfigurations.<config>.system
```

### Test NixOS modules
```bash
# Build NixOS configuration
nix build .#nixosConfigurations.<config>.config.system.build.toplevel
```

## Git Commands
Standard git commands for version control:
```bash
git status
git add <files>
git commit -m "message"
git push
```

## Darwin-specific Commands

### List files in directory (BSD ls)
```bash
# Note: macOS uses BSD ls, not GNU ls
ls -la
```

### Find files (BSD find)
```bash
# Note: macOS uses BSD find, not GNU find
find . -name "*.nix"
```

### Grep (BSD grep)
```bash
# Note: macOS uses BSD grep
grep -r "pattern" .
```
