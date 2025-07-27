"""Example of model-aware orchestrator."""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../..'))

from ai_agents.base_agents.model_aware_agent import ModelAwareAgent


class SmartOrchestrator(ModelAwareAgent):
    """Example orchestrator that intelligently selects models."""
    
    def __init__(self):
        super().__init__("orchestrator", default_model="auto")

    def process_task(self, task):
        """Process a task with automatic model selection."""
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

        # Moderate task - model selected based on context
        elif task["type"] == "code_review":
            file_count = len(task.get("files", []))
            return self.execute_with_model(
                task_type="code_review",
                description=f"Review {file_count} files for code quality",
                task_fn=lambda model: self._review_code(task["data"], model),
                file_count=file_count
            )

    def _generate_summary(self, data, model):
        """Generate summary using selected model."""
        print(f"[{self.agent_name}] Generating summary with {model}")
        # In real implementation, this would call the actual model API
        return f"Summary generated using {model}"

    def _debug_issue(self, data, model):
        """Debug complex issue using selected model."""
        print(f"[{self.agent_name}] Debugging issue with {model}")
        # In real implementation, this would call the actual model API
        return f"Issue debugged using {model}"

    def _review_code(self, data, model):
        """Review code using selected model."""
        print(f"[{self.agent_name}] Reviewing code with {model}")
        # In real implementation, this would call the actual model API
        return f"Code reviewed using {model}"


# Example usage
if __name__ == "__main__":
    orchestrator = SmartOrchestrator()
    
    # Test different task types
    tasks = [
        {
            "type": "generate_summary",
            "data": {"logs": ["log1", "log2"]}
        },
        {
            "type": "debug_issue",
            "data": {"error": "Service timeout"},
            "previous_attempts": 3
        },
        {
            "type": "code_review",
            "data": {"changes": ["file1.py", "file2.py"]},
            "files": ["file1.py", "file2.py", "file3.py"]
        }
    ]
    
    print("=== SmartOrchestrator Example ===\n")
    
    for i, task in enumerate(tasks, 1):
        print(f"Task {i}: {task['type']}")
        result = orchestrator.process_task(task)
        print(f"Result: {result}\n")
    
    print("\nCheck ./usage_metrics.jsonl for logged model decisions")