# CDC DevTools

Cloud Data Consulting Developer Toolkit - Shared tools and utilities for the CDC team.

## Overview

CDC DevTools provides a comprehensive set of tools and utilities to standardize and enhance developer workflows across the Cloud Data Consulting team. This includes tmux orchestration, AI agent frameworks, monitoring dashboards, and team onboarding automation.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/CloudDataConsulting/cdc-devtools.git ~/repos/cdc/cdc-devtools

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

## Directory Structure

```
cdc-devtools/
├── tmux-orchestration/    # Tmux session management
├── ai-agents/            # AI agent components
├── monitoring/           # Monitoring and alerting
├── team-setup/          # Onboarding and config
└── bin/                 # Executable shortcuts
```

## Available Commands

After setup, these commands are available in your PATH:

- `cdc-create-session` - Create a new project session
- `cdc-monitor` - Launch the unified monitoring dashboard
- `cdc-onboard` - Onboard a new developer
- `cdc-logs` - View CDC logs

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