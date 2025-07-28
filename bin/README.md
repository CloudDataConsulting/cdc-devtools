# CDC DevTools Commands

This directory contains symbolic links to all CDC DevTools executable commands. After installation, these commands are available globally in your PATH.

## Available Commands

### Session Management

#### `cdc-create-session`
Create and manage tmux sessions with CDC DevTools integration.

```bash
# Basic usage
cdc-create-session SESSION_NAME PROJECT_PATH

# With template
cdc-create-session -t ai-agent-project mybot ~/repos/mybot

# Custom layout
cdc-create-session -l tiled -p 4 analytics ~/repos/analytics

# Options:
#   -t TEMPLATE    Template type (basic-project, ai-agent-project)
#   -l LAYOUT      Tmux layout (even-horizontal, even-vertical, main-horizontal, tiled)
#   -p PANES       Number of panes in main window (default: 3)
#   -h             Show help
```

### Monitoring and Analytics

#### `cdc-monitor`
Launch the unified monitoring dashboard for all CDC sessions.

```bash
# Start monitoring
cdc-monitor

# Custom refresh rate (seconds)
cdc-monitor -r 10

# Kill monitoring dashboard
cdc-monitor -k

# Options:
#   -r RATE    Refresh rate in seconds (default: 5)
#   -k         Kill the monitoring dashboard
#   -h         Show help
```

#### `cdc-monitor-project`
Monitor a specific project's tmux session.

```bash
# Monitor current directory's project
cdc-monitor-project

# Monitor specific project
cdc-monitor-project ~/repos/myproject

# Options:
#   PROJECT_PATH    Path to project (default: current directory)
```

#### `cdc-analyze-models`
Analyze AI model usage and provide cost optimization recommendations.

```bash
# Basic analysis
cdc-analyze-models

# Date range analysis
cdc-analyze-models --from 2024-01-01 --to 2024-01-31

# Cost report
cdc-analyze-models --cost-report

# Optimization recommendations
cdc-analyze-models --optimize

# Test configuration
cdc-analyze-models --test

# Options:
#   --from DATE       Start date (YYYY-MM-DD)
#   --to DATE         End date (YYYY-MM-DD)
#   --cost-report     Generate detailed cost report
#   --optimize        Show optimization opportunities
#   --test            Test configuration and access
```

#### `cdc-git-monitor`
Monitor AI agent git activity in real-time.

```bash
# Monitor current repository
cdc-git-monitor

# Monitor specific repository
cdc-git-monitor ~/repos/myproject

# Generate activity report
cdc-git-monitor --report

# Show statistics
cdc-git-monitor --stats

# Live monitoring mode
cdc-git-monitor --live

# Options:
#   --report    Generate activity report
#   --stats     Show commit statistics
#   --live      Live monitoring mode
#   --agent     Filter by specific agent
```

### Project Management

#### `cdc-import-project`
Import existing projects and add CDC DevTools integration.

```bash
# Basic import
cdc-import-project PROJECT_PATH

# With project name and type
cdc-import-project -n "My ML Bot" -t ai-agent-project ~/repos/ml-bot

# Force overwrite existing configuration
cdc-import-project -f ~/repos/existing-project

# Options:
#   -n NAME      Project name
#   -t TYPE      Project type (basic-project, ai-agent-project)
#   -f           Force overwrite existing configuration
#   -h           Show help
```

### Developer Tools

#### `cdc-onboard`
Onboard new team members with automated setup.

```bash
# Interactive onboarding
cdc-onboard

# With parameters
cdc-onboard -n "John Doe" -e "john@clouddataconsulting.com"

# Skip confirmations
cdc-onboard -y -n "Jane Smith" -e "jane@clouddataconsulting.com"

# Options:
#   -n NAME     Developer name
#   -e EMAIL    Developer email
#   -y          Skip confirmation prompts
#   -h          Show help
```

#### `cdc-summary`
Generate work summaries from session logs.

```bash
# Today's summary
cdc-summary

# Specific date
cdc-summary 2024-01-15

# Date range
cdc-summary --from 2024-01-01 --to 2024-01-31

# Specific session
cdc-summary --session myproject

# Options:
#   DATE              Specific date (YYYY-MM-DD)
#   --from DATE       Start date
#   --to DATE         End date
#   --session NAME    Specific session name
```

#### `cdc-logs`
View and search CDC DevTools logs.

```bash
# View recent logs
cdc-logs

# Follow logs in real-time
cdc-logs -f

# Filter by level
cdc-logs --level ERROR

# Search logs
cdc-logs --grep "model usage"

# Specific date
cdc-logs --date 2024-01-15

# Options:
#   -f, --follow      Follow logs in real-time
#   --level LEVEL     Filter by log level (DEBUG, INFO, WARN, ERROR)
#   --grep PATTERN    Search for pattern
#   --date DATE       Specific date (YYYY-MM-DD)
#   --session NAME    Filter by session
```

### Utility Commands

#### `cdc-health-check`
Check system health and configuration.

```bash
# Run health check
cdc-health-check

# Verbose output
cdc-health-check -v

# Fix common issues
cdc-health-check --fix

# Options:
#   -v, --verbose    Verbose output
#   --fix            Attempt to fix issues
```

#### `cdc-config`
Manage CDC DevTools configuration.

```bash
# Show current configuration
cdc-config

# Edit global configuration
cdc-config --edit

# Edit project configuration
cdc-config --project

# Reset to defaults
cdc-config --reset

# Options:
#   --edit       Edit global configuration
#   --project    Edit project configuration
#   --reset      Reset to default configuration
```

## Command Structure

All commands follow these conventions:

1. **Prefix**: All commands start with `cdc-` for easy discovery
2. **Help**: All commands support `-h` or `--help` flags
3. **Verbosity**: Most commands support `-v` for verbose output
4. **Configuration**: Commands respect `~/.cdc/config` settings

## Adding New Commands

To add a new command:

1. Create the script in the appropriate subdirectory:
   ```bash
   vim ~/repos/cdc/cdc-devtools/category/my-script.sh
   chmod +x ~/repos/cdc/cdc-devtools/category/my-script.sh
   ```

2. Create symbolic link in bin/:
   ```bash
   cd ~/repos/cdc/cdc-devtools/bin
   ln -s ../category/my-script.sh cdc-my-command
   ```

3. Update this README with documentation

4. Test the command:
   ```bash
   cdc-my-command -h
   ```

## Environment Variables

Commands respect these environment variables:

- `CDC_HOME`: CDC configuration directory (default: `~/.cdc`)
- `CDC_LOG_DIR`: Log directory (default: `~/.cdc/logs`)
- `CDC_LOG_LEVEL`: Logging verbosity (0-3, default: 1)
- `CDC_DEBUG`: Enable debug mode (true/false)
- `CDC_SESSION_NAME`: Current tmux session name
- `CDC_PROJECT_PATH`: Current project path

## Troubleshooting

### Command not found

```bash
# Verify installation
ls -la ~/repos/cdc/cdc-devtools/bin/

# Check PATH
echo $PATH | grep -q cdc-devtools || echo "Not in PATH"

# Re-run installation
cd ~/repos/cdc/cdc-devtools/developer-config && ./install.sh
```

### Permission denied

```bash
# Fix permissions
chmod +x ~/repos/cdc/cdc-devtools/bin/cdc-*
chmod +x ~/repos/cdc/cdc-devtools/*/cdc-*.sh
```

### Debugging commands

```bash
# Enable debug mode
export CDC_DEBUG=true
export CDC_LOG_LEVEL=0

# Run command with bash debugging
bash -x $(which cdc-command)
```

## Best Practices

1. **Use help flags**: Always check `-h` for available options
2. **Check logs**: Use `cdc-logs` to troubleshoot issues
3. **Monitor actively**: Keep `cdc-monitor` running during work
4. **Regular analysis**: Run `cdc-analyze-models` weekly
5. **Stay updated**: Pull latest changes regularly

## Support

- **Issues**: Check `cdc-logs` first
- **Help**: Run commands with `-h` flag
- **Slack**: #devtools-support
- **GitHub**: Open issue with command output