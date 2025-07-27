# Analyze and Merge Personal Config into CDC DevTools

Please analyze my `.bpruss_config` repository and merge appropriate components into CDC DevTools as a generic configuration system for the entire team.

## 1. Analyze Current Repository

First, explore the `.bpruss_config` repository located at `~/.bpruss_config`:

### Categories to Look For:
- Shell configurations (.zshrc, .bashrc, aliases)
- Git configurations
- Tool configurations (tmux, vim, etc.)
- Claude/AI configurations
- SSH configurations (structure only, not keys)
- Environment variables and secrets management
- Personal scripts and utilities

### Create Analysis Report:
List what you find and categorize as:
- **Team-Shareable**: Configurations that would benefit all CDC team members
- **Personal**: Settings specific to me that should remain private
- **Templates**: Personal configs that could become templates for others

## 2. Design Generic Configuration System

Create a new structure in CDC DevTools for team configurations:

```
cdc-devtools/
└── developer-config/           # Not hidden - it's a shared repo component
    ├── README.md              # How to use CDC developer configs
    ├── shell/
    │   ├── aliases.sh         # Common CDC aliases
    │   ├── functions.sh       # Shared shell functions
    │   └── completions.sh     # Tool completions
    ├── git/
    │   ├── gitconfig.template # Team git settings
    │   └── gitignore.global   # Standard ignores
    ├── tmux/
    │   └── tmux.conf.cdc      # CDC tmux configuration
    ├── templates/
    │   ├── .zshrc.template    # Template for new developers
    │   └── .env.template      # Environment variable template
    └── install.sh             # Sets up configs for a developer
```

## 3. Extract and Generalize Components

From my `.bpruss_config`, extract and generalize:

### Shell Configurations
- Take my aliases and functions
- Remove personal paths (replace with variables like `$CDC_WORKSPACE`)
- Remove personal credentials
- Keep useful productivity aliases
- Generalize project paths

Example transformation:
```bash
# Personal (don't include)
alias aub="cd ~/repos/aub/MDM-dbt/dbt && aubdbt && code ."

# Generic (include)
alias cdc-workspace="cd $CDC_WORKSPACE"
alias tf="terraform"  # Keep generic tool aliases
```

### Environment Management
- Convert my environment setup to templates
- Create a system for managing secrets without storing them
- Use placeholders for personal values

### Tool Configurations
- Extract tmux configurations that improve productivity
- Git aliases and settings that help the team
- Any other tool configs that are generally useful

## 4. Create Installation System

Create `developer-config/install.sh` that:

```bash
#!/bin/bash
# CDC Developer Config Installation

echo "🚀 Setting up CDC Developer Configurations"

# 1. Back up existing configs
# 2. Create symlinks or copy templates
# 3. Prompt for personal values (name, email, etc.)
# 4. Set up CDC-specific paths

# Don't overwrite, but offer to merge
if [ -f ~/.zshrc ]; then
    echo "Found existing .zshrc"
    echo "Would you like to:"
    echo "1) Add CDC config to existing .zshrc"
    echo "2) Replace with CDC template"
    echo "3) Skip"
fi
```

## 5. Create Personal Config Handler

Since some configs need to remain personal, create a system for that:

```
developer-config/
└── personal/
    ├── README.md           # How to maintain personal configs
    ├── .gitignore         # Ignore actual personal files
    └── example-personal.sh # Example structure
```

## 6. Migration Guide

Create documentation for migrating from `.bpruss_config`:

```markdown
# Migrating from Personal Config to CDC DevTools

## What Moved Where
- Shell aliases → `developer-config/shell/aliases.sh`
- Git config → `developer-config/git/gitconfig.template`
- Personal scripts → Evaluate for `cdc-devtools/bin/`

## Setting Up Your Personal Config
1. Run `./developer-config/install.sh`
2. Add personal items to `~/.cdc_personal`
3. Your `.zshrc` will source both CDC and personal configs
```

## 7. Handle Sensitive Patterns

For items like:
- SSH key paths (keep structure, not keys)
- API credentials (create template with placeholders)
- Personal project paths (use environment variables)

Create templates showing the pattern without exposing secrets:

```bash
# developer-config/templates/.env.template
export CDC_WORKSPACE="$HOME/repos"
export CDC_DEFAULT_REGION="us-east-1"
export CDC_GITHUB_TOKEN=""  # Add your token here
```

## 8. Preserve Personal Workflows

If I have specific workflows (like the `aubdbt` function), create a way for team members to have their own client-specific configurations:

```bash
# developer-config/shell/functions.sh
# Source client-specific functions if they exist
if [ -f ~/.cdc_clients ]; then
    source ~/.cdc_clients
fi
```

## After Analysis

Once you've analyzed `.bpruss_config`, please:
1. Show me what you found
2. Propose what should be moved to CDC DevTools
3. Identify what should remain personal
4. Create the generic versions in CDC DevTools
5. Set up the installation system

## Important Notes

- Keep the shared config in `developer-config/` (not hidden) since it's part of the repo
- Personal configs on user machines can be `~/.cdc_config` (hidden)
- Make everything optional - developers should be able to pick what they want
- Use templates and variables rather than hardcoded personal values
- Preserve the functionality while making it generic

The goal is to give CDC team members a quick way to get productive configurations while maintaining flexibility for personal preferences!
