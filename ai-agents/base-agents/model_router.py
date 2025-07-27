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