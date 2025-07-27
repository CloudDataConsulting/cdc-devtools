"""Base agent class with automated git operations."""

from .git_manager import GitManager
from typing import Optional, Dict, Any
import functools


class GitAwareAgent:
    """Base agent that automatically commits work."""

    def __init__(
        self,
        agent_name: str,
        repo_path: str = ".",
        auto_commit: bool = True,
        branch_name: Optional[str] = None
    ):
        self.agent_name = agent_name
        self.git = GitManager(
            repo_path=repo_path,
            agent_name=agent_name,
            auto_push=auto_commit
        )

        if branch_name:
            self.git.ensure_branch(branch_name)

    def track_changes(func):
        """Decorator to track file changes from methods."""
        @functools.wraps(func)
        def wrapper(self, *args, **kwargs):
            # Before the operation
            files_before = set()  # Would scan directory

            # Execute the operation
            result = func(self, *args, **kwargs)

            # After the operation
            files_after = set()  # Would scan directory again

            # Track changes
            for file in files_after - files_before:
                self.git.track_file_change(file, "created")

            # Check if we should commit
            if hasattr(result, '__dict__') and result.__dict__.get('commit_now'):
                self.git.commit_checkpoint({
                    'task_completed': True,
                    'task_name': func.__name__,
                    'description': result.__dict__.get('description', '')
                })

            return result
        return wrapper

    def complete_task(self, task_name: str, description: str = ""):
        """Mark task as complete and commit."""
        self.git.commit_checkpoint({
            'task_completed': True,
            'task_name': task_name,
            'description': description
        })

    def save_progress(self, description: str):
        """Save progress checkpoint."""
        self.git.commit_current_work(
            f"Progress: {description[:50]}",
            detailed_description=description
        )

    def handle_error(self, error: Exception, solution: str = ""):
        """Commit after handling an error."""
        self.git.commit_checkpoint({
            'error_fixed': True,
            'error_description': str(error)[:100],
            'solution': solution
        })