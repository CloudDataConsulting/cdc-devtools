# Implement Smart Model Router for CDC DevTools

Add a model routing system to optimize usage of Claude Opus vs Sonnet models across our AI agents.

## 1. Create Model Router Base Module

Create `ai-agents/base-agents/model_router.py` with:

```python
"""
Smart model router for CDC AI Agents.
Routes tasks to appropriate Claude model based on complexity and requirements.
"""

from enum import Enum
from typing import Dict, Optional, Any
import json
import os
from datetime import datetime


class ModelType(Enum):
    OPUS = "claude-opus-4-20250514"
    SONNET = "claude-3-5-sonnet-20241022"


class TaskComplexity(Enum):
    SIMPLE = 1      # File ops, formatting
    BASIC = 2       # Test writing, basic code
    MODERATE = 3    # Standard development
    COMPLEX = 4     # Architecture, debugging
    CRITICAL = 5    # Production, orchestration


class ModelRouter:
    """Route tasks to appropriate Claude model based on complexity."""

    # Keywords that trigger Opus usage
    OPUS_TRIGGERS = [
        "architect", "orchestrate", "design", "strategy",
        "debug", "complex", "critical", "production",
        "refactor", "analyze system", "review architecture"
    ]

    # Task complexity scores
    TASK_COMPLEXITY = {
        # Simple tasks (Sonnet)
        "file_operation": TaskComplexity.SIMPLE,
        "code_format": TaskComplexity.SIMPLE,
        "log_analysis": TaskComplexity.SIMPLE,
        "generate_summary": TaskComplexity.SIMPLE,
        "write_test": TaskComplexity.BASIC,
        "update_docs": TaskComplexity.BASIC,
        "sql_query": TaskComplexity.BASIC,

        # Moderate tasks (Usually Sonnet, sometimes Opus)
        "code_generation": TaskComplexity.MODERATE,
        "bug_fix": TaskComplexity.MODERATE,
        "code_review": TaskComplexity.MODERATE,

        # Complex tasks (Usually Opus)
        "system_design": TaskComplexity.COMPLEX,
        "debug_complex": TaskComplexity.COMPLEX,
        "architecture_review": TaskComplexity.CRITICAL,
        "orchestration": TaskComplexity.CRITICAL,
    }

    def __init__(self, default_threshold: int = 4):
        self.default_threshold = default_threshold
        self.usage_log_path = os.getenv('CDC_USAGE_LOG', './usage_metrics.jsonl')

    def select_model(
        self,
        task_type: str,
        description: str,
        context: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Select appropriate model based on task complexity.

        Args:
            task_type: Type of task (e.g., 'code_generation', 'log_analysis')
            description: Description of the specific task
            context: Additional context (errors, production flag, etc.)

        Returns:
            Model identifier string
        """
        # Check for explicit Opus triggers in description
        description_lower = description.lower()
        if any(trigger in description_lower for trigger in self.OPUS_TRIGGERS):
            self._log_decision(task_type, "OPUS", "trigger_word", description)
            return ModelType.OPUS.value

        # Get base complexity score
        complexity = self.TASK_COMPLEXITY.get(task_type, TaskComplexity.MODERATE)
        score = complexity.value

        # Adjust based on context
        if context:
            # Multiple failures indicate complex issue
            if context.get("retry_count", 0) > 1:
                score += 1
            if context.get("errors_count", 0) > 2:
                score += 2

            # Production always gets premium treatment
            if context.get("production", False):
                score += 2

            # Large scope increases complexity
            if context.get("file_count", 0) > 10:
                score += 1
            if context.get("line_count", 0) > 1000:
                score += 1

        # Select model based on final score
        model = ModelType.OPUS.value if score >= self.default_threshold else ModelType.SONNET.value
        self._log_decision(task_type, model, "complexity_score", description, score)

        return model

    def _log_decision(
        self,
        task_type: str,
        model: str,
        reason: str,
        description: str,
        score: Optional[int] = None
    ):
        """Log model selection decision for analysis."""
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "task_type": task_type,
            "model": model,
            "reason": reason,
            "description": description[:100],  # Truncate long descriptions
            "score": score
        }

        try:
            with open(self.usage_log_path, 'a') as f:
                f.write(json.dumps(log_entry) + '\n')
        except Exception as e:
            # Don't fail if logging fails
            pass
```

## 2. Create Usage Tracker

Create `ai-agents/base-agents/usage_tracker.py`:

```python
"""Track and analyze model usage for optimization."""

import json
from datetime import datetime, timedelta
from collections import defaultdict
from typing import Dict, List, Tuple


class UsageTracker:
    """Track model usage and provide insights."""

    def __init__(self, log_path: str = './usage_metrics.jsonl'):
        self.log_path = log_path

    def log_usage(
        self,
        model: str,
        task_type: str,
        tokens_used: int,
        success: bool,
        duration_seconds: float
    ):
        """Log usage metrics."""
        entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "model": model,
            "task_type": task_type,
            "tokens_used": tokens_used,
            "success": success,
            "duration_seconds": duration_seconds
        }

        with open(self.log_path, 'a') as f:
            f.write(json.dumps(entry) + '\n')

    def analyze_usage(self, days: int = 7) -> Dict:
        """Analyze recent usage patterns."""
        cutoff = datetime.utcnow() - timedelta(days=days)

        stats = {
            "opus": {"count": 0, "tokens": 0, "success_rate": 0},
            "sonnet": {"count": 0, "tokens": 0, "success_rate": 0},
            "task_distribution": defaultdict(lambda: {"opus": 0, "sonnet": 0}),
            "potential_savings": 0
        }

        opus_successes = []
        sonnet_successes = []

        with open(self.log_path, 'r') as f:
            for line in f:
                entry = json.loads(line)
                timestamp = datetime.fromisoformat(entry["timestamp"])

                if timestamp < cutoff:
                    continue

                model_key = "opus" if "opus" in entry["model"] else "sonnet"
                stats[model_key]["count"] += 1
                stats[model_key]["tokens"] += entry.get("tokens_used", 0)

                if model_key == "opus":
                    opus_successes.append(entry["success"])
                else:
                    sonnet_successes.append(entry["success"])

                task = entry.get("task_type", "unknown")
                stats["task_distribution"][task][model_key] += 1

        # Calculate success rates
        if opus_successes:
            stats["opus"]["success_rate"] = sum(opus_successes) / len(opus_successes)
        if sonnet_successes:
            stats["sonnet"]["success_rate"] = sum(sonnet_successes) / len(sonnet_successes)

        # Identify optimization opportunities
        for task, counts in stats["task_distribution"].items():
            if counts["opus"] > counts["sonnet"] and task in ["log_analysis", "generate_summary", "file_operation"]:
                stats["potential_savings"] += counts["opus"]

        return stats

    def get_recommendations(self) -> List[str]:
        """Get recommendations for model usage optimization."""
        stats = self.analyze_usage()
        recommendations = []

        if stats["potential_savings"] > 10:
            recommendations.append(
                f"Consider moving {stats['potential_savings']} simple tasks from Opus to Sonnet"
            )

        # Check success rates
        opus_rate = stats["opus"]["success_rate"]
        sonnet_rate = stats["sonnet"]["success_rate"]

        if sonnet_rate > 0.95 and opus_rate < sonnet_rate:
            recommendations.append(
                "Sonnet is performing very well - consider expanding its usage"
            )

        return recommendations
```

## 3. Create Integration Helper

Create `ai-agents/base-agents/model_aware_agent.py`:

```python
"""Base class for model-aware agents."""

from .model_router import ModelRouter
from .usage_tracker import UsageTracker
import time


class ModelAwareAgent:
    """Base agent class with intelligent model selection."""

    def __init__(self, agent_name: str, default_model: str = "auto"):
        self.agent_name = agent_name
        self.default_model = default_model
        self.router = ModelRouter()
        self.tracker = UsageTracker()

    def select_model_for_task(self, task_type: str, description: str, **context) -> str:
        """Select appropriate model for task."""
        if self.default_model != "auto":
            return self.default_model

        return self.router.select_model(task_type, description, context)

    def execute_with_model(self, task_type: str, description: str, task_fn, **context):
        """Execute task with appropriate model and track usage."""
        model = self.select_model_for_task(task_type, description, **context)

        start_time = time.time()
        try:
            # In real implementation, this would set up the model
            result = task_fn(model=model)
            success = True
        except Exception as e:
            result = None
            success = False

            # Consider retrying with Opus if Sonnet failed
            if "sonnet" in model and context.get("allow_upgrade", True):
                model = self.router.ModelType.OPUS.value
                result = task_fn(model=model)
                success = True

        duration = time.time() - start_time

        # Track usage (tokens would come from actual API response)
        self.tracker.log_usage(
            model=model,
            task_type=task_type,
            tokens_used=0,  # Would get from API
            success=success,
            duration_seconds=duration
        )

        return result
```

## 4. Create Configuration Template

Create `ai-agents/config/model_routing.yaml`:

```yaml
# Model routing configuration for CDC AI Agents
model_routing:
  default_threshold: 4  # Complexity score threshold for Opus

  # Force specific models for certain agents
  agent_overrides:
    log_analyzer: sonnet
    test_writer: sonnet
    doc_generator: sonnet
    system_architect: opus
    orchestrator: opus

  # Task-specific overrides
  task_overrides:
    generate_readme: sonnet
    format_code: sonnet
    analyze_logs: sonnet
    design_system: opus
    debug_production: opus

  # Context triggers that upgrade to Opus
  upgrade_triggers:
    - production_environment
    - multiple_failures
    - client_critical
    - architecture_change
```

## 5. Create Usage Analysis Script

Create `monitoring/analyze_model_usage.py`:

```python
#!/usr/bin/env python3
"""Analyze model usage and provide optimization recommendations."""

from ai_agents.base_agents.usage_tracker import UsageTracker
import sys


def main():
    tracker = UsageTracker()

    # Get analysis period from args
    days = int(sys.argv[1]) if len(sys.argv) > 1 else 7

    print(f"=== Model Usage Analysis (Last {days} days) ===\n")

    stats = tracker.analyze_usage(days)

    print(f"Opus Usage:")
    print(f"  Requests: {stats['opus']['count']}")
    print(f"  Success Rate: {stats['opus']['success_rate']:.2%}")
    print(f"  Total Tokens: {stats['opus']['tokens']:,}")

    print(f"\nSonnet Usage:")
    print(f"  Requests: {stats['sonnet']['count']}")
    print(f"  Success Rate: {stats['sonnet']['success_rate']:.2%}")
    print(f"  Total Tokens: {stats['sonnet']['tokens']:,}")

    print(f"\nTask Distribution:")
    for task, counts in stats['task_distribution'].items():
        print(f"  {task}: Opus={counts['opus']}, Sonnet={counts['sonnet']}")

    print(f"\nOptimization Opportunities:")
    recommendations = tracker.get_recommendations()
    for rec in recommendations:
        print(f"  - {rec}")

    if stats['potential_savings'] > 0:
        print(f"\n💰 Potential Opus requests that could use Sonnet: {stats['potential_savings']}")


if __name__ == "__main__":
    main()
```

## 6. Create Example Integration

Create `ai-agents/examples/model_aware_orchestrator.py` showing how to use the system:

```python
"""Example of model-aware orchestrator."""

from ai_agents.base_agents.model_aware_agent import ModelAwareAgent


class SmartOrchestrator(ModelAwareAgent):
    def __init__(self):
        super().__init__("orchestrator", default_model="auto")

    def process_task(self, task):
        # Simple task - will use Sonnet
        if task["type"] == "generate_summary":
            return self.execute_with_model(
                task_type="generate_summary",
                description="Create daily summary from logs",
                task_fn=lambda model: self._generate_summary(task["data"], model)
            )

        # Complex task - will use Opus
        elif task["type"] == "debug_issue":
            return self.execute_with_model(
                task_type="debug_complex",
                description="Debug production issue with multiple service failures",
                task_fn=lambda model: self._debug_issue(task["data"], model),
                production=True,
                errors_count=task.get("previous_attempts", 0)
            )
```

## 7. Update Documentation

Add to `ai-agents/README.md`:

```markdown
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
python monitoring/analyze_model_usage.py 30  # Last 30 days
```
```

## 8. Add to bin/

Create symlink:
- `cdc-analyze-models` → `monitoring/analyze_model_usage.py`

This system will help optimize model usage across all CDC projects while maintaining quality where it matters!
