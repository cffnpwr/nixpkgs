# Task Completion Checklist

When completing a task, ensure you perform the following steps:

## 1. Code Quality
- [ ] Format code using `nix fmt`
- [ ] Verify code follows project conventions (see code_style_and_conventions.md)
- [ ] Ensure proper indentation (2 spaces)
- [ ] Add appropriate documentation strings

## 2. Testing
- [ ] Run `nix flake check` to verify flake structure
- [ ] Build affected packages: `nix build .#<package>`
- [ ] Test module loading (if applicable)
- [ ] Verify platform-specific code works correctly

## 3. Documentation
- [ ] Update module documentation if options changed
- [ ] Add examples for new options
- [ ] Update README.md if adding new features (only if explicitly requested)

## 4. Git Operations
- [ ] Stage changed files: `git add <files>`
- [ ] Create meaningful commit message
- [ ] Verify git status before committing

## 5. Module-Specific Checks

### For new/modified modules:
- [ ] Verify option types are correct
- [ ] Ensure default values are sensible
- [ ] Add platform checks if needed (isDarwin/isLinux)
- [ ] Use `lib.mkIf` for conditional configuration
- [ ] Test with both enabled and disabled states

### For programs modules:
- [ ] Package installation is handled
- [ ] Configuration files are generated correctly
- [ ] XDG paths are used appropriately

### For services modules:
- [ ] Systemd/launchd service is defined
- [ ] Service dependencies are declared
- [ ] Restart behavior is appropriate
- [ ] Log paths are configured

## 6. No Formatting/Testing Errors
- [ ] Run formatter: `nix fmt`
- [ ] No flake check errors: `nix flake check`
- [ ] All builds succeed

## Note
Some checks may not apply to all tasks. Use judgment to determine which are relevant for the specific task at hand.
