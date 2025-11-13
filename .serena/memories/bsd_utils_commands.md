# BSD Utils Commands (Darwin/macOS)

This project is developed on Darwin (macOS), which uses BSD utilities instead of GNU utilities.

## Important Differences from GNU Tools

### ls (List files)
```bash
# BSD ls doesn't support --color=auto
ls -la          # List all with details
ls -lh          # Human-readable sizes
ls -ltr         # Sort by time, reverse
```

### find (Find files)
```bash
# BSD find has different syntax
find . -name "*.nix"                    # Find by name
find . -type f -name "*.nix"            # Find files only
find . -type d -name "modules"          # Find directories
```

### grep (Search in files)
```bash
# BSD grep has limited features
grep -r "pattern" .                     # Recursive search
grep -n "pattern" file.nix              # Show line numbers
grep -i "pattern" file.nix              # Case insensitive
```

### sed (Stream editor)
```bash
# BSD sed requires -i with extension or empty string
sed -i '' 's/old/new/g' file.nix        # In-place edit (no backup)
sed -i .bak 's/old/new/g' file.nix      # In-place with backup
```

### xargs
```bash
# BSD xargs doesn't support -r flag
find . -name "*.nix" | xargs grep "pattern"
```

## Recommended Alternatives in Nix Shell

When in `nix develop`, GNU tools are available:
```bash
# The development shell provides:
- git (standard)
- nil (Nix LSP)
- nixd (Nix daemon)
- nixfmt-rfc-style (formatter)
```

## File Operations
```bash
# Standard file operations work the same
cd <directory>      # Change directory
pwd                 # Print working directory
mkdir <dir>         # Create directory
rm <file>           # Remove file
cp <src> <dst>      # Copy file
mv <src> <dst>      # Move/rename file
```

## Process Management
```bash
ps aux              # List processes
kill <pid>          # Kill process
killall <name>      # Kill by name
```
