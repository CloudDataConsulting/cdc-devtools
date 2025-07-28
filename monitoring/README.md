# CDC Monitoring Tools

Advanced Python-based monitoring and analytics tools for CDC DevTools projects.

## Overview

The monitoring suite provides intelligent analytics and cost optimization for AI-powered development workflows. These tools integrate seamlessly with tmux orchestration to provide real-time insights and automated optimizations.

## Core Components

### 1. Model Usage Analytics (`analyze_model_usage.py`)

Analyzes Claude model usage patterns to optimize costs while maintaining quality.

**Features:**
- Tracks usage of different Claude models (Opus vs Sonnet)
- Analyzes success rates and token consumption
- Provides cost optimization recommendations
- Identifies opportunities to downgrade from Opus to Sonnet
- Generates detailed usage reports

**Usage:**
```bash
# Analyze recent usage
cdc-analyze-models

# Analyze specific date range
cdc-analyze-models --from 2024-01-01 --to 2024-01-31

# Generate cost report
cdc-analyze-models --cost-report

# Show optimization opportunities
cdc-analyze-models --optimize
```

**Integration:**
- Automatically collects data from Claude interactions
- Logs stored in `~/.cdc/logs/model_usage/`
- Integrates with tmux monitoring windows

### 2. Git Activity Monitor (`git_activity_monitor.py`)

Tracks and categorizes AI agent git commits to understand productivity patterns.

**Features:**
- Real-time monitoring of AI git commits
- Categorizes commits by type (feature, bugfix, test, docs, refactor)
- Tracks commits per agent and project
- Generates activity reports and statistics
- Identifies productivity patterns

**Usage:**
```bash
# Monitor current project
cdc-git-monitor

# Monitor specific repository
cdc-git-monitor ~/repos/cdc/myproject

# Generate activity report
cdc-git-monitor --report

# Show statistics by agent
cdc-git-monitor --stats
```

**Git Aliases:**
```bash
# View AI commits
git ai-log

# Show AI commit statistics
git ai-stats

# Filter commits by agent
git ai-log --agent orchestrator
```

### 3. Smart Model Router (`model_router.py`)

Intelligently routes tasks to appropriate Claude models based on complexity.

**Features:**
- Analyzes task complexity using keywords and patterns
- Routes simple tasks to Sonnet for cost savings
- Uses Opus for complex reasoning and coding
- Logs routing decisions for analysis
- Learns from success patterns

**Routing Logic:**
- **Sonnet**: Simple queries, documentation, basic code edits
- **Opus**: Complex algorithms, architectural decisions, debugging

**Configuration:**
```python
# In your agent configuration
from monitoring.model_router import ModelRouter

router = ModelRouter()
model = router.select_model(task_description, context)
```

### 4. Tmux-Aware Secrets Manager (`tmux_aware_secrets.py`)

Context-aware secrets management that adapts to tmux window context.

**Features:**
- Detects current tmux window and pane
- Loads appropriate secrets per window context
- Validates configurations match window purpose
- Supports dynamic configuration switching
- Integrates with 1Password CLI

**Usage:**
```python
from monitoring.tmux_aware_secrets import TmuxAwareSecrets

secrets = TmuxAwareSecrets()
# Automatically loads correct config for current window
api_key = secrets.get('api_key')
```

**Window Configurations:**
- `main`: General development credentials
- `agent-*`: Agent-specific API keys
- `monitoring`: Monitoring service credentials
- `deploy`: Deployment and production secrets

## Integration with Tmux Orchestration

### Automatic Setup

When creating AI agent projects, monitoring is automatically configured:

```bash
cdc-create-session -t ai-agent-project mybot ~/repos/mybot
```

This creates:
- Dedicated monitoring window with split panes
- Model usage tracking pane
- Git activity monitor pane
- Resource usage display
- Alerts and notifications pane

### Environment Variables

The tmux session sets environment variables for Python tools:
- `CDC_SESSION_NAME`: Current session identifier
- `CDC_PROJECT_PATH`: Project root directory
- `CDC_WINDOW_TYPE`: Window purpose (main, agent, monitoring)
- `CDC_AGENT_NAME`: For agent-specific windows

### Data Flow

```
Claude API Calls → Logging Framework → Model Usage Analytics
                                    ↓
Git Commits → Git Hooks → Activity Monitor → Reports
                        ↓
                  Tmux Windows → Real-time Display
```

## Cost Optimization Strategies

### 1. Automatic Model Selection

The system tracks success rates and automatically suggests model downgrades:

```bash
# Check optimization opportunities
cdc-analyze-models --optimize

# Example output:
# Optimization Opportunities Found:
# - Documentation tasks: 95% success with Sonnet (save $0.12/1K tokens)
# - Code formatting: 98% success with Sonnet (save $0.12/1K tokens)
# - Simple queries: 92% success with Sonnet (save $0.12/1K tokens)
# Potential monthly savings: $847.20
```

### 2. Task Batching

Combine related tasks to reduce API calls:
- Group similar operations
- Batch documentation updates
- Consolidate code reviews

### 3. Caching Strategy

Intelligent caching reduces redundant API calls:
- Cache common responses
- Reuse analysis results
- Share context between agents

## Monitoring Dashboard

### Launch Unified Dashboard
```bash
cdc-monitor
```

Features:
- Real-time session status
- Resource usage graphs
- Model usage statistics
- Git activity timeline
- Cost tracking
- Alert notifications

### Custom Dashboards

Create project-specific monitoring:

```bash
# In .cdc-project.conf
MONITOR_LAYOUT="custom"
MONITOR_PANES=(
    "watch -n 5 cdc-analyze-models --current"
    "cdc-git-monitor --live"
    "htop -F CDC"
    "tail -f ~/.cdc/logs/cdc-*.log | grep ERROR"
)
```

## Configuration

### Global Settings

Edit `~/.cdc/monitoring.conf`:

```bash
# Model routing preferences
MODEL_ROUTING_ENABLED=true
DEFAULT_MODEL=sonnet
COMPLEX_TASK_MODEL=opus

# Git monitoring
GIT_MONITOR_BRANCHES="main,develop"
GIT_MONITOR_INTERVAL=30

# Cost thresholds
DAILY_COST_ALERT=50.00
HOURLY_TOKEN_ALERT=100000
```

### Per-Project Settings

In `.cdc-project.conf`:

```bash
# Project-specific monitoring
ENABLE_MODEL_ANALYTICS=true
ENABLE_GIT_MONITORING=true
MONITORING_INTERVAL=60

# Cost controls
MAX_DAILY_COST=100.00
PREFERRED_MODEL=sonnet
```

## Troubleshooting

### Common Issues

1. **No model usage data**
   - Check `~/.cdc/logs/model_usage/` exists
   - Verify Claude API calls are being logged
   - Run `cdc-analyze-models --test`

2. **Git monitoring not working**
   - Ensure git hooks are installed: `cdc-import-project -f .`
   - Check git config: `git config --get cdc.monitoring`
   - Verify repository has commits

3. **Tmux context not detected**
   - Check `$TMUX` environment variable
   - Verify window naming: `tmux list-windows`
   - Test with `python -m monitoring.tmux_aware_secrets --test`

### Debug Mode

Enable verbose logging:

```bash
export CDC_LOG_LEVEL=0  # DEBUG level
export CDC_MONITOR_DEBUG=true
```

## Best Practices

1. **Regular Analysis**: Run `cdc-analyze-models` weekly to identify optimization opportunities

2. **Agent Configuration**: Configure agents to use the model router for automatic optimization

3. **Cost Alerts**: Set up daily cost alerts to catch unusual usage patterns

4. **Git Commit Standards**: Ensure AI agents use consistent commit message formats for better categorization

5. **Window Organization**: Keep monitoring windows visible during development for real-time insights

## Contributing

To add new monitoring capabilities:

1. Create module in `/monitoring/`
2. Add command wrapper in `/bin/`
3. Update tmux templates if needed
4. Document in this README
5. Add tests in `/monitoring/tests/`

## Support

- **Logs**: `~/.cdc/logs/monitoring/`
- **Config**: `~/.cdc/monitoring.conf`
- **Slack**: #dev-monitoring
- **Issues**: GitHub Issues with `monitoring` label