# CDC Developer Configuration

Standardized developer configurations for the Cloud Data Consulting team.

## Overview

This directory contains optional, team-wide configurations to help CDC developers get productive quickly. All configurations are modular and can be selectively installed.

## Quick Start

```bash
# Install all CDC developer configs
./install.sh

# Or install specific components
./install.sh --shell    # Just shell aliases and functions
./install.sh --git      # Just git configuration
./install.sh --minimal  # Minimal setup without overwriting
```

## Directory Structure

```
developer-config/
├── shell/              # Shell configurations
│   ├── aliases.sh      # Common aliases (git, terraform, etc.)
│   ├── functions.sh    # Shared shell functions
│   └── completions.sh  # Tool completions
├── git/                # Git configurations
│   ├── gitconfig.template
│   └── gitignore.global
├── tmux/               # Tmux configurations
│   └── tmux.conf.cdc
├── templates/          # Configuration templates
│   ├── .zshrc.template
│   ├── .bashrc.template
│   └── .env.template
└── personal/           # Personal config examples
    └── README.md
```

## What's Included

### Shell Configurations

- **Git aliases**: `g`, `gs`, `gf`, `gl`, `gg` for common operations
- **Terraform aliases**: `tf`, `tfi`, `tfp`, `tfa` for faster terraform
- **AWS aliases**: Shortcuts for common AWS operations
- **Utility functions**: Project navigation, environment loading

### Git Configuration

- Useful aliases like `graph` for visual log
- Branch cleanup commands
- Sensible defaults for cross-platform development
- Git LFS support

### Templates

- Environment variable templates
- Shell RC file templates
- Personal configuration examples

## Installation

The install script will:
1. Back up your existing configurations
2. Ask before overwriting any files
3. Let you choose which components to install
4. Set up CDC workspace variables

## Personal Configurations

Your personal settings belong in:
- `~/.cdc_personal` - Personal aliases and functions
- `~/.cdc_clients` - Client-specific configurations
- `~/.cdc_env` - Personal environment variables

These files are automatically sourced if they exist.

## Customization

### Adding Client Configs

Create `~/.cdc_clients` with client-specific aliases:

```bash
# Aubuchon shortcuts
alias aub="cd $CDC_WORKSPACE/aub/MDM-dbt && source env.sh"

# Other client shortcuts
alias client2="cd $CDC_WORKSPACE/client2"
```

### Personal Aliases

Add personal aliases to `~/.cdc_personal`:

```bash
# Your personal shortcuts
alias myproject="cd ~/personal/project"
```

## Best Practices

1. **Don't commit secrets** - Use templates with placeholders
2. **Keep it modular** - Separate concerns into different files
3. **Document everything** - Help your teammates understand
4. **Make it optional** - Don't force configurations

## Contributing

To add new team-wide configurations:

1. Add to appropriate subdirectory
2. Update the install script
3. Document in this README
4. Test on both macOS and Linux (WSL)