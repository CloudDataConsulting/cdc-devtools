"""Base class for model-aware agents."""

from .model_router import ModelRouter, ModelType
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