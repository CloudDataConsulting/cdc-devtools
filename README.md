# CDC DevTools

Cloud Data Consulting Developer Toolkit - Shared tools and utilities for the CDC team.

## Overview

CDC DevTools provides a comprehensive set of tools and utilities to standardize and enhance developer workflows across the Cloud Data Consulting team. This includes tmux orchestration, AI agent frameworks, monitoring dashboards, and team onboarding automation.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/CloudDataConsulting/cdc-devtools.git ~/repos/cdc/cdc-devtools

# Install CDC developer configurations
cd ~/repos/cdc/cdc-devtools/developer-config
./install.sh

# Run the onboarding script
cd ~/repos/cdc/cdc-devtools
./team-setup/onboard_developer.sh -n "Your Name" -e "your.email@clouddataconsulting.com"

# Restart your shell or source your rc file
source ~/.zshrc  # or ~/.bashrc

# Create your first project session
cdc-create-session myproject ~/repos/cdc/myproject
```

## Key Features

### 🖥️ Tmux Orchestration
- Standardized project session management
- Integrated logging and monitoring
- Template-based project setups
- Automatic pane configuration

### 🤖 AI Agent Framework
- Reusable agent components
- Multi-agent orchestration
- Example implementations
- Best practices documentation

### 📊 Unified Monitoring
- Real-time session monitoring
- Resource usage tracking
- Health checks and alerts
- Slack integration

### 👥 Team Setup
- Automated developer onboarding
- Standardized configurations
- Tool installation verification
- Environment setup

### 🔧 Developer Configuration
- Standardized shell aliases and functions
- Git configuration templates
- Tmux productivity settings
- Personal customization support

## Directory Structure

```
cdc-devtools/
├── tmux-orchestration/    # Tmux session management
├── ai-agents/            # AI agent components
├── monitoring/           # Monitoring and alerting
├── team-setup/          # Onboarding and config
├── developer-config/    # Shell configs and dotfiles
└── bin/                 # Executable shortcuts
```

## Available Commands

After setup, these commands are available in your PATH:

- `cdc-create-session` - Create a new project session with logging
- `cdc-monitor` - Launch the unified monitoring dashboard
- `cdc-monitor-project` - Monitor a specific project
- `cdc-onboard` - Onboard a new developer
- `cdc-import-project` - Import existing project with CDC tools
- `cdc-summary` - Generate work summary from logs
- `cdc-analyze-models` - Analyze AI model usage and costs
- `cdc-git-monitor` - Monitor AI agent git activity
- `cdc-logs` - View CDC logs

## Importing Existing Projects

To add CDC DevTools to an existing project:

```bash
# Basic import
cdc-import-project ~/repos/myproject

# Import with specific type
cdc-import-project -n "My ML Bot" -t ai-agent-project ~/repos/ml-bot

# Force overwrite existing config
cdc-import-project -f ~/repos/existing-project
```

This will:
- Create a `.cdc-project.conf` configuration file
- Set up logging directories
- Update `.gitignore` with CDC entries
- Add CDC section to README
- Configure git hooks for commit tracking

## Configuration Files

Projects use `.cdc-project.conf` files to define:
- Project name and type
- AI agents (for AI projects)
- Custom tmux windows
- Logging preferences
- Monitoring settings

Example for AI projects:
```bash
AGENTS=(
    "orchestrator:Main Orchestrator"
    "data:Data Processing Agent"
    "model:Model Training Agent"
)
```

## Automated Git Workflow

AI agents automatically commit and push their work:

- **Auto-commits** after logical checkpoints
- **Smart branching** for different types of work
- **Detailed commit messages** with context
- **Activity monitoring** to track AI contributions

### View AI Commits

```bash
# See all AI commits
git ai-log

# See AI commit statistics
git ai-stats

# Monitor AI git activity
cdc-git-monitor
```

### Configuration

Agents inherit from `GitAwareAgent` to get automatic commits:

```python
class MyAgent(GitAwareAgent):
    def process_task(self, task):
        # ... do work ...
        self.complete_task("Task Done", "Description")
        # Automatically commits and pushes!
```

## Developer Configuration

CDC DevTools includes optional shell configurations to standardize common developer tasks:

- **Git aliases**: `g`, `gs`, `gf`, `gl` for faster git operations
- **Terraform shortcuts**: `tf`, `tfi`, `tfp` for infrastructure work
- **AWS utilities**: Profile management and authentication helpers
- **Project navigation**: Quick access to CDC projects

See [developer-config/README.md](developer-config/README.md) for installation and customization.

## Contributing

1. Fork the repository
2. Create a feature branch (`feature/your-feature`)
3. Make your changes
4. Submit a pull request

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup and contribution guidelines.

## Support

- **Slack**: #dev-tools
- **Email**: devtools@clouddataconsulting.com
- **Issues**: [GitHub Issues](https://github.com/CloudDataConsulting/cdc-devtools/issues)

## License

© 2024 Cloud Data Consulting. Internal use only.