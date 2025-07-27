# CDC Tmux Orchestration

Standardized tmux session management for CDC projects with integrated logging and monitoring.

## Overview

The tmux orchestration toolkit provides:
- Consistent project session creation
- Integrated logging framework
- Real-time monitoring capabilities
- Template-based project setups

## Quick Start

```bash
# Create a new project session
cdc-create-session myproject ~/repos/cdc/myproject

# Create session with template
cdc-create-session -t ai-agent-project aibot ~/repos/cdc/aibot

# Monitor all sessions
cdc-monitor
```

## Core Components

### 1. Logging Framework (`core/logging_framework.sh`)
- Consistent logging across all CDC tools
- Log levels: DEBUG, INFO, WARN, ERROR
- Automatic log rotation
- Session tracking

### 2. Session Creator (`core/create_project_session.sh`)
- Creates standardized tmux sessions
- Configurable layouts and pane counts
- Template support
- Automatic monitoring window

### 3. Monitoring Base (`core/monitoring_base.sh`)
- Session health checks
- Resource usage tracking
- Real-time status updates

## Templates

Templates provide pre-configured session setups for specific project types:

- `basic-project/` - Standard development setup
- `ai-agent-project/` - AI/ML project configuration

## Environment Variables

- `CDC_LOG_DIR` - Log directory (default: `~/.cdc/logs`)
- `CDC_LOG_LEVEL` - Logging level (0-3)
- `CDC_MONITOR_INTERVAL` - Monitoring refresh rate
- `CDC_SESSION_NAME` - Current session name
- `CDC_PROJECT_PATH` - Project directory path

## Best Practices

1. Always use `cdc-create-session` for new projects
2. Keep monitoring window open for visibility
3. Check logs regularly in `~/.cdc/logs`
4. Use templates for consistent project setups

## Troubleshooting

- **Session already exists**: Kill with `tmux kill-session -t SESSION_NAME`
- **Can't attach**: Check if already in tmux with `echo $TMUX`
- **Missing logs**: Ensure `CDC_LOG_DIR` exists and is writable