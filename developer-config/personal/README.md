# Personal Configuration Examples

This directory contains examples of personal configurations that developers can create in their home directories.

## Configuration Files

CDC DevTools looks for these personal configuration files:

### ~/.cdc_personal
Personal aliases, functions, and settings that are specific to you.

```bash
#!/usr/bin/env bash
# Personal aliases
alias myproject="cd ~/personal/my-project"
alias notes="code ~/Documents/notes"

# Personal functions
personal_backup() {
    rsync -av ~/Documents/ /Volumes/Backup/Documents/
}

# Personal environment
export MY_PERSONAL_VAR="value"
```

### ~/.cdc_clients
Client-specific configurations and shortcuts.

```bash
#!/usr/bin/env bash
# Client shortcuts
alias aub="cd $CDC_WORKSPACE/aubuchon && source env.sh"
alias aubdbt="cd $CDC_WORKSPACE/aub/MDM-dbt && source env.sh"
alias client2="cd $CDC_WORKSPACE/client2"

# Client-specific functions
aub_deploy() {
    echo "Deploying to Aubuchon..."
    cd $CDC_WORKSPACE/aubuchon
    ./deploy.sh "$@"
}
```

### ~/.cdc_env
Personal environment variables that shouldn't be in version control.

```bash
#!/usr/bin/env bash
# Personal tokens and credentials
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
export PERSONAL_API_KEY="sk-xxxxxxxxxxxx"

# Personal preferences
export SNOWFLAKE_DEFAULT_ROLE="MY_PREFERRED_ROLE"
export AWS_DEFAULT_PROFILE="my-personal-profile"

# Override CDC defaults
export CDC_WORKSPACE="$HOME/work/cdc"  # If you use a different path
```

## Best Practices

1. **Keep Secrets Secure**
   - Never commit these files to version control
   - Use password managers (1Password) for sensitive values
   - Consider using encrypted storage for credentials

2. **Organize by Purpose**
   - Personal shortcuts in `~/.cdc_personal`
   - Client work in `~/.cdc_clients`
   - Environment variables in `~/.cdc_env`

3. **Document Your Setup**
   - Add comments to explain complex functions
   - Keep a personal README with your setup notes
   - Document any dependencies

## Example: Complete Personal Setup

### ~/.cdc_personal
```bash
#!/usr/bin/env bash
# Bernie's Personal CDC Configuration

# Quick access to personal projects
alias blog="cd ~/projects/personal-blog"
alias dotfiles="cd ~/dotfiles"

# Personal git shortcuts
alias gpp="git push personal"  # Push to personal remote

# Custom functions
review_prs() {
    # Open all PRs assigned to me
    gh pr list --assignee @me --web
}

# Override default editor for personal preference
export EDITOR='nvim'
```

### ~/.cdc_clients
```bash
#!/usr/bin/env bash
# Client-Specific Configurations

# Aubuchon shortcuts
alias aub="cd $CDC_WORKSPACE/aubuchon && source env.sh"
alias aubtest="cd $CDC_WORKSPACE/aubuchon && source env_test.sh"

aubdbt() {
    cd "$CDC_WORKSPACE/aub/MDM-dbt" || return
    source env.sh
    echo "Aubuchon DBT environment loaded"
}

# CloudData shortcuts
alias cdprod="aws sso login --profile clouddata-prd"
alias cddev="aws sso login --profile clouddata-dev"

# Client-specific Snowflake connections
sf_aub() {
    export SNOWFLAKE_ACCOUNT="aubuchon-prd"
    export SNOWFLAKE_USER="bernie.pruss@clouddataconsulting.com"
    echo "Switched to Aubuchon Snowflake"
}
```

### ~/.cdc_env
```bash
#!/usr/bin/env bash
# Personal Environment Variables

# 1Password Service Account (for CLI access)
export OP_SERVICE_ACCOUNT_TOKEN="eyJhbGc..."

# Personal AWS preferences
export AWS_PAGER=""  # Disable pager for AWS CLI
export AWS_DEFAULT_OUTPUT="table"

# Personal tool preferences
export BAT_THEME="Dracula"
export FZF_DEFAULT_OPTS="--height 40% --reverse"

# Override workspace if needed
# export CDC_WORKSPACE="$HOME/work/cdc"
```

## Integration with Shell

These files are automatically sourced by the CDC configuration. The loading order is:

1. CDC aliases (`~/.cdc/aliases.sh`)
2. CDC functions (`~/.cdc/functions.sh`)
3. Personal config (`~/.cdc_personal`)
4. Client config (`~/.cdc_clients`)
5. Environment (`~/.cdc_env`)

This ensures your personal settings override CDC defaults when needed.

## Tips

1. **Start Simple**: Begin with a few aliases and grow your configuration over time
2. **Version Control**: Consider keeping these in a private dotfiles repo
3. **Backup**: Regularly backup your personal configurations
4. **Review**: Periodically review and clean up unused configurations
5. **Share**: Share useful patterns with the team (sanitized of personal data)