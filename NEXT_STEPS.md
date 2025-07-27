# CDC DevTools - Next Steps

## Setup Instructions for New Team Members

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/CloudDataConsulting/cdc-devtools.git ~/repos/cdc/cdc-devtools

# Run the onboarding script
cd ~/repos/cdc/cdc-devtools
./team-setup/onboard_developer.sh -n "Your Name" -e "your.email@clouddataconsulting.com"

# Restart your shell
exec $SHELL
```

### 2. Verify Installation

```bash
# Check that commands are available
which cdc-create-session
which cdc-monitor
which cdc-onboard

# View your configuration
cat ~/.cdc/config
```

## Creating a New Project Session

### Basic Usage

```bash
# Create a session for an existing project
cdc-create-session myproject ~/repos/cdc/myproject

# Create a session with AI agent template
cdc-create-session -t ai-agent-project ml-bot ~/repos/cdc/ml-bot

# Create a session with custom layout
cdc-create-session -l tiled -p 4 analytics ~/repos/cdc/analytics
```

### Session Management

```bash
# List active sessions
tmux ls

# Attach to a session
tmux attach -t session-name

# Switch between sessions (while in tmux)
Ctrl-b s  # Then select session

# Kill a session
tmux kill-session -t session-name
```

## Contributing New Tools

### 1. Adding a New Script

```bash
# Create your script
vim ~/repos/cdc/cdc-devtools/new-category/my-script.sh

# Make it executable
chmod +x ~/repos/cdc/cdc-devtools/new-category/my-script.sh

# Add to bin/ if it should be globally accessible
cd ~/repos/cdc/cdc-devtools/bin
ln -s ../new-category/my-script.sh cdc-my-command

# Commit and push
git add -A
git commit -m "Add new script for X functionality"
git push
```

### 2. Creating a New Template

```bash
# Create template directory
mkdir -p ~/repos/cdc/cdc-devtools/tmux-orchestration/templates/my-template

# Create setup script
cat > ~/repos/cdc/cdc-devtools/tmux-orchestration/templates/my-template/setup.sh << 'EOF'
#!/usr/bin/env bash
apply_template() {
    local session=$1
    local project_path=$2
    
    log_info "Applying my-template"
    # Your custom setup here
}
EOF

# Make executable
chmod +x ~/repos/cdc/cdc-devtools/tmux-orchestration/templates/my-template/setup.sh

# Test it
cdc-create-session -t my-template test ~/tmp/test
```

### 3. Updating Documentation

Always update documentation when adding new features:

1. Update README.md if adding major functionality
2. Update SETUP_GUIDE.md if changing setup process
3. Add inline documentation to scripts
4. Include examples in commit messages

## Monitoring and Debugging

### View Logs

```bash
# Real-time log viewing
cdc-logs

# Filter logs by date
ls ~/.cdc/logs/

# Search logs
grep "ERROR" ~/.cdc/logs/cdc-*.log

# Session-specific logs
grep "session-name" ~/.cdc/logs/cdc-*.log
```

### Monitor All Sessions

```bash
# Start monitoring dashboard
cdc-monitor

# Custom refresh rate
cdc-monitor -r 10

# Kill monitoring dashboard
cdc-monitor -k
```

## Best Practices

1. **Always use cdc-create-session** for new projects
   - Ensures consistent setup
   - Enables logging automatically
   - Provides monitoring capabilities

2. **Commit frequently** to the devtools repo
   - Share improvements with the team
   - Document changes clearly
   - Test before pushing

3. **Use templates** for project types
   - AI projects: `-t ai-agent-project`
   - Basic projects: default or `-t basic-project`
   - Create custom templates for your workflow

4. **Monitor actively**
   - Keep `cdc-monitor` running on a separate screen
   - Check logs for errors regularly
   - Set up Slack alerts for critical issues

## Support Channels

- **Slack**: #dev-tools
- **GitHub Issues**: https://github.com/CloudDataConsulting/cdc-devtools/issues
- **Email**: devtools@clouddataconsulting.com
- **Wiki**: Internal CDC Wiki > Developer Tools

## Roadmap

Upcoming features and improvements:

1. **Import existing projects** - Tool to add CDC tooling to existing repos
2. **More templates** - Data pipeline, API service, Snowflake project
3. **Enhanced monitoring** - Grafana integration, metric collection
4. **CI/CD integration** - GitHub Actions templates
5. **Cloud deployment** - Scripts for AWS/GCP setup

To contribute to these features, check the GitHub issues or discuss in #dev-tools.