# CDC DevTools Setup Guide

Comprehensive setup and usage guide for CDC Developer Tools.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Usage Examples](#usage-examples)
5. [Customization](#customization)
6. [Troubleshooting](#troubleshooting)
7. [Contributing](#contributing)

## Prerequisites

Before setting up CDC DevTools, ensure you have:

- **Git** (2.30+)
- **Tmux** (3.0+)
- **GitHub CLI** (`gh`)
- **Bash** or **Zsh** shell
- **Python** (3.8+) for monitoring tools

### Installing Prerequisites

#### macOS
```bash
brew install git tmux gh python@3.11
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install git tmux python3 python3-pip
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

## Installation

### 1. Clone the Repository

```bash
mkdir -p ~/repos/cdc
git clone https://github.com/CloudDataConsulting/cdc-devtools.git ~/repos/cdc/cdc-devtools
```

### 2. Run Onboarding Script

```bash
cd ~/repos/cdc/cdc-devtools
./team-setup/onboard_developer.sh -n "Your Name" -e "your.email@clouddataconsulting.com" -t "Your Team"
```

### 3. Reload Shell Configuration

```bash
# For Zsh
source ~/.zshrc

# For Bash
source ~/.bashrc
```

### 4. Verify Installation

```bash
# Check if commands are available
which cdc-create-session
which cdc-monitor

# Check configuration
cat ~/.cdc/config
```

## Configuration

### Environment Variables

Key environment variables set by the onboarding script:

```bash
CDC_HOME="$HOME/.cdc"                    # CDC home directory
CDC_LOG_DIR="$HOME/.cdc/logs"           # Log directory
CDC_LOG_LEVEL=1                         # 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR
CDC_MONITOR_INTERVAL=5                  # Monitor refresh interval
CDC_DEVTOOLS_PATH="$HOME/repos/cdc/cdc-devtools"
```

### Custom Configuration

Edit `~/.cdc/config` to customize settings:

```bash
# Example: Change log level to DEBUG
export CDC_LOG_LEVEL=0

# Example: Change monitor refresh rate
export CDC_MONITOR_INTERVAL=10
```

### Slack Integration

To enable Slack notifications:

```bash
# Add to ~/.cdc/config or shell RC file
export CDC_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

## Usage Examples

### Creating Project Sessions

#### Basic Session
```bash
cdc-create-session myproject ~/repos/cdc/myproject
```

#### Session with Custom Layout
```bash
# 4 panes in tiled layout
cdc-create-session -l tiled -p 4 analytics ~/repos/cdc/analytics
```

#### Session with Template
```bash
# Use AI agent project template
cdc-create-session -t ai-agent-project ml-bot ~/repos/cdc/ml-bot
```

### Monitoring

#### Start Monitoring Dashboard
```bash
cdc-monitor
```

#### Custom Refresh Rate
```bash
cdc-monitor -r 10  # 10 second refresh
```

#### Detached Mode
```bash
cdc-monitor -d  # Create dashboard without attaching
```

### Working with Sessions

#### List Active Sessions
```bash
tmux ls
```

#### Attach to Existing Session
```bash
tmux attach -t session-name
```

#### Kill Session
```bash
tmux kill-session -t session-name
```

### Viewing Logs

#### Real-time Logs
```bash
cdc-logs  # Alias for tail -f ~/.cdc/logs/cdc-*.log
```

#### Filter by Session
```bash
grep "session-name" ~/.cdc/logs/cdc-*.log
```

#### Error/Warning Only
```bash
tail -f ~/.cdc/logs/cdc-*.log | grep -E "ERROR|WARN"
```

## Customization

### Creating Custom Templates

1. Create template directory:
```bash
mkdir -p ~/repos/cdc/cdc-devtools/tmux-orchestration/templates/my-template
```

2. Create setup script:
```bash
cat > ~/repos/cdc/cdc-devtools/tmux-orchestration/templates/my-template/setup.sh << 'EOF'
#!/usr/bin/env bash
apply_template() {
    local session=$1
    local project_path=$2
    
    log_info "Applying my-template"
    
    # Your custom setup here
    tmux send-keys -t "$session:0.0" "echo 'Custom template!'" C-m
}
EOF
```

3. Make executable:
```bash
chmod +x ~/repos/cdc/cdc-devtools/tmux-orchestration/templates/my-template/setup.sh
```

4. Use template:
```bash
cdc-create-session -t my-template project ~/repos/project
```

### Adding Custom Commands

Add to `~/.cdc/config` or shell RC:

```bash
# Custom aliases
alias cdc-status='tmux ls && echo && cdc-logs | tail -20'
alias cdc-clean='find $CDC_LOG_DIR -name "*.log" -mtime +7 -delete'

# Custom functions
cdc-switch() {
    tmux switch-client -t "$1" 2>/dev/null || tmux attach -t "$1"
}
```

## Troubleshooting

### Common Issues

#### "Command not found"
- Ensure `~/repos/cdc/cdc-devtools/bin` is in PATH
- Reload shell configuration

#### "Session already exists"
```bash
# Kill existing session
tmux kill-session -t session-name
```

#### "Cannot attach: no sessions"
```bash
# List available sessions
tmux ls

# Create new session if none exist
cdc-create-session test ~/repos/test
```

#### Permission Denied
```bash
# Fix script permissions
chmod +x ~/repos/cdc/cdc-devtools/**/*.sh
```

### Debug Mode

Enable debug logging:
```bash
export CDC_LOG_LEVEL=0
cdc-create-session debug-test ~/repos/test
```

### Log Locations

- Session logs: `~/.cdc/logs/cdc-YYYYMMDD.log`
- Tmux server logs: `tmux show-messages`
- System logs: Check `/var/log/syslog` or journalctl

## Contributing

### Development Workflow

1. **Fork and Clone**
```bash
gh repo fork CloudDataConsulting/cdc-devtools --clone
```

2. **Create Feature Branch**
```bash
git checkout -b feature/your-feature
```

3. **Make Changes**
- Follow existing code style
- Add tests if applicable
- Update documentation

4. **Test Locally**
```bash
# Test scripts
./tmux-orchestration/core/create_project_session.sh test ~/tmp/test

# Check syntax
shellcheck tmux-orchestration/**/*.sh
```

5. **Submit PR**
```bash
git push origin feature/your-feature
gh pr create
```

### Code Standards

- Use consistent indentation (4 spaces)
- Add error handling
- Include usage documentation
- Follow CDC naming conventions
- Test on both macOS and Linux

### Testing

Before submitting:
1. Test all modified scripts
2. Verify no breaking changes
3. Update relevant documentation
4. Add examples if introducing new features

## Advanced Topics

### Integration with CI/CD

```yaml
# Example: GitHub Actions
- name: Setup CDC DevTools
  run: |
    git clone https://github.com/CloudDataConsulting/cdc-devtools.git
    ./cdc-devtools/team-setup/onboard_developer.sh -n "CI Bot" -e "ci@cdc.com" -s
```

### Remote Session Management

```bash
# SSH with tmux forwarding
ssh -t user@host "tmux attach -t session-name"

# Create remote session
ssh user@host "cd ~/repos/project && cdc-create-session remote-project ."
```

### Backup and Restore

```bash
# Backup CDC configuration
tar -czf cdc-backup-$(date +%Y%m%d).tar.gz ~/.cdc

# Restore
tar -xzf cdc-backup-20240101.tar.gz -C ~/
```

## Support

Need help? Reach out through:

- **Slack**: #dev-tools
- **Email**: devtools@clouddataconsulting.com
- **GitHub Issues**: [Create an issue](https://github.com/CloudDataConsulting/cdc-devtools/issues/new)