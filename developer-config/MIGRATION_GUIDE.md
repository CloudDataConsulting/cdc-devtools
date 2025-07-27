# CDC Developer Configuration Migration Guide

This guide helps you migrate from personal dotfiles to the CDC Developer Configuration system.

## Overview

The CDC Developer Configuration provides a standardized foundation while preserving your personal customizations. This migration is designed to be non-destructive and reversible.

## Pre-Migration Checklist

- [ ] Backup your current shell configuration files
- [ ] Note any custom aliases, functions, or settings you want to keep
- [ ] Identify client-specific configurations
- [ ] Review your git configuration for personal settings

## Migration Steps

### 1. Backup Current Configuration

The installer automatically backs up your files, but it's good to make your own copy:

```bash
# Create a manual backup
mkdir ~/dotfiles_backup_$(date +%Y%m%d)
cp ~/.bashrc ~/.zshrc ~/.gitconfig ~/dotfiles_backup_$(date +%Y%m%d)/
```

### 2. Run the Installer

```bash
cd ~/repos/cdc/cdc-devtools/developer-config
./install.sh
```

Choose installation options:
- `--all`: Install everything (recommended for new setups)
- `--minimal`: Skip files that already exist
- `--shell --git`: Install only specific components

### 3. Migrate Personal Configurations

#### From .bpruss-config Style

If you have a `.bpruss-config` style setup:

1. **Shell Aliases**: Move personal aliases to `~/.cdc_personal`
   ```bash
   # From: ~/.bpruss-config/shell/aliases_personal.sh
   # To: ~/.cdc_personal
   
   # Copy personal aliases, removing CDC-standard ones
   grep -E "alias (myproject|personal|custom)" ~/.bpruss-config/shell/aliases_personal.sh >> ~/.cdc_personal
   ```

2. **Client Configs**: Move to `~/.cdc_clients`
   ```bash
   # From: Scattered client functions
   # To: ~/.cdc_clients
   
   # Move client-specific aliases and functions
   ```

3. **Environment Variables**: Move to `~/.cdc_env`
   ```bash
   # From: Various env files
   # To: ~/.cdc_env
   
   # Move personal tokens, paths, and preferences
   ```

#### From Standard Dotfiles

If you have traditional dotfiles:

1. **Extract Personal Aliases**
   ```bash
   # Review your current aliases
   alias | grep -v "^(g=|gs=|tf=)" > my_personal_aliases.txt
   
   # Add unique ones to ~/.cdc_personal
   ```

2. **Extract Personal Functions**
   ```bash
   # Review functions in your .bashrc/.zshrc
   # Copy non-CDC functions to ~/.cdc_personal
   ```

### 4. Update Git Configuration

The installer preserves your git user settings. To merge CDC git aliases:

```bash
# Review the generated config
cat ~/.gitconfig.cdc_new

# Manually merge desired aliases into your ~/.gitconfig
```

### 5. Test Your Configuration

```bash
# Reload your shell
source ~/.$(basename $SHELL)rc

# Test CDC commands
cdc  # Should go to CDC workspace
gs   # Should run git status

# Test personal commands
# Your personal aliases should still work
```

### 6. Clean Up

Once everything is working:

1. Remove old configuration files you've migrated
2. Update your dotfiles repository if you have one
3. Document any custom changes in `~/.cdc_personal`

## Common Migration Patterns

### AWS Profiles

**Before**: Hardcoded in shell files
```bash
export AWS_PROFILE=mycompany-dev
```

**After**: In project env.sh or ~/.cdc_clients
```bash
# In ~/.cdc_clients
alias mycompany="export AWS_PROFILE=mycompany-dev"
```

### Project Navigation

**Before**: Personal aliases
```bash
alias proj="cd ~/projects/my-project"
```

**After**: Organized by type
```bash
# CDC projects in functions
cdcp my-project

# Personal projects in ~/.cdc_personal
alias proj="cd ~/projects/my-project"
```

### Credential Management

**Before**: Environment variables in .bashrc
```bash
export SECRET_TOKEN="xxx"
```

**After**: Using 1Password or ~/.cdc_env
```bash
# In ~/.cdc_env (not in version control)
export SECRET_TOKEN=$(op read "op://vault/item/token")
```

## Rollback Instructions

If you need to revert:

1. The installer creates backups in `~/.cdc_config_backup_[timestamp]`
2. Restore your original files:
   ```bash
   cp ~/.cdc_config_backup_*/.[!.]* ~/
   ```
3. Remove CDC configuration lines from your shell RC file

## FAQ

### Q: Will this overwrite my personal settings?
A: No, the installer backs up existing files and personal configs are kept separate.

### Q: Can I use this with my existing dotfiles manager?
A: Yes, you can symlink the CDC files or source them from your dotfiles.

### Q: What if I don't want certain CDC aliases?
A: Override them in your `~/.cdc_personal` file:
```bash
unalias g  # Remove CDC alias
alias g="grip"  # Set your own
```

### Q: How do I update CDC configurations?
A: Run `cdc-update` to pull the latest from the repository.

## Support

If you encounter issues during migration:

1. Check the backup directory for your original files
2. Review the error messages from the installer
3. Ask in the CDC Slack channel
4. Create an issue in the cdc-devtools repository