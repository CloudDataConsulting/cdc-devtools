# CDC AI Agents

This directory contains two complementary types of AI agent resources for CDC projects.

## Overview

### 1. Claude Agent Prompts (`claude-prompts/`)
Pre-written instructions for Claude to act as specialized agents:
- **What**: Markdown files containing expert role definitions and methodologies
- **Use**: Copy into Claude.ai interface or use with Anthropic API
- **Browse**: See `claude-prompts/AGENT_REGISTRY.md` for full catalog
- **Categories**: Core, Data, DevOps agents for different specialties

### 2. Python Agent Framework (`python-framework/`)
Programmatic agent implementations for automated workflows:
- **What**: Python classes for building intelligent agents
- **Use**: Import and extend in your Python projects
- **Features**: Model routing, Git integration, orchestration
- **Examples**: See `examples/` for implementation patterns

## Quick Start

### Using Claude Prompts
```bash
# 1. Browse available agents
cat claude-prompts/AGENT_REGISTRY.md

# 2. Copy desired agent
cat claude-prompts/data-agents/snowflake-architect-pro.md

# 3. Paste into Claude and add your requirements
```

### Using Python Framework
```python
# Import base classes
from ai_agents.python_framework import ModelAwareAgent, GitAwareAgent

# Create your agent
class MyAgent(ModelAwareAgent):
    def process(self, task):
        # Agent logic here
        pass
```

## Directory Structure

```
ai-agents/
├── claude-prompts/         # Claude agent instructions
│   ├── core-agents/        # General-purpose agents
│   ├── data-agents/        # Data engineering specialists
│   ├── devops-agents/      # Infrastructure experts
│   ├── templates/          # Templates for new agents
│   └── AGENT_REGISTRY.md   # Complete catalog
├── python-framework/       # Python implementations
│   ├── __init__.py
│   ├── base_agent.py       # Base classes
│   ├── model_router.py     # Smart model selection
│   └── git_manager.py      # Git automation
├── orchestrators/          # Multi-agent coordination
├── examples/               # Example implementations
└── config/                 # Configuration files
```

## When to Use Each Type

### Use Claude Prompts When:
- Working interactively with Claude
- Need expert guidance and methodology
- Designing architecture or strategy
- Reviewing code or documentation
- One-off or exploratory tasks

### Use Python Framework When:
- Building automated systems
- Need programmatic control
- Integrating with CI/CD pipelines
- Processing batches of tasks
- Requiring deterministic behavior

## Development Guidelines

1. All agents should inherit from `BaseAgent`
2. Use standardized logging (CDC logging framework)
3. Implement proper error handling
4. Document agent capabilities and limitations
5. Include unit tests for each agent

## Common Patterns

### 1. Single Agent
- Simple request-response pattern
- Stateless processing
- Direct integration

### 2. Multi-Agent Orchestra
- Coordinator manages multiple agents
- Parallel or sequential processing
- Result aggregation

### 3. Agent Pipeline
- Chain of agents
- Data transformation at each step
- Error propagation handling

## Intelligent Model Routing

CDC DevTools includes smart model routing to optimize costs while maintaining quality:

- **Automatic Selection**: Routes tasks to Opus or Sonnet based on complexity
- **Usage Tracking**: Monitor model usage and success rates
- **Cost Optimization**: Identify opportunities to use Sonnet for simple tasks

### Quick Start

```python
from ai_agents.base_agents.model_aware_agent import ModelAwareAgent

class MyAgent(ModelAwareAgent):
    def process(self, task):
        return self.execute_with_model(
            task_type="code_generation",
            description=task["description"],
            task_fn=lambda model: self.generate_code(task, model)
        )
```

### View Usage Analytics

```bash
cdc-analyze-models     # Last 7 days
cdc-analyze-models 30  # Last 30 days
```

### Model Selection Logic

The router considers:
1. **Task Type**: Simple tasks (logs, formatting) → Sonnet; Complex tasks (architecture, debug) → Opus
2. **Keywords**: Triggers like "production", "critical", "architect" → Opus
3. **Context**: Error count, file count, retry attempts affect model selection
4. **Configuration**: Override defaults in `config/model_routing.yaml`

## Best Practices

- Keep agents focused on single responsibilities
- Use dependency injection for flexibility
- Implement timeouts for all operations
- Monitor agent performance metrics
- Version agent models and configurations
- Let the router handle model selection unless you have specific requirements

## Examples

See the `examples/` directory for:
- Model-aware orchestrator (`model_aware_orchestrator.py`)
- Text processing agents
- Data analysis agents
- Integration agents
- Monitoring agents