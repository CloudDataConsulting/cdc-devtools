# CDC AI Agents

Reusable AI agent components and orchestration patterns for CDC projects.

## Overview

This directory contains:
- Base agent implementations
- Orchestration frameworks
- Example implementations
- Best practices for AI agent development

## Directory Structure

- `base-agents/` - Foundational agent classes and utilities
- `orchestrators/` - Multi-agent coordination systems
- `examples/` - Reference implementations

## Getting Started

```python
# Example: Using a base agent
from cdc_agents.base import BaseAgent

class MyAgent(BaseAgent):
    def process(self, input_data):
        # Agent logic here
        pass
```

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