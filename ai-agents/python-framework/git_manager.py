"""
Automated git operations for AI agents.
Commits and pushes work automatically at logical checkpoints.
"""

import subprocess
import os
from datetime import datetime
from typing import List, Optional, Dict, Tuple
import json


class GitManager:
    """Handle automated git operations for AI agents."""

    def __init__(
        self,
        repo_path: str = ".",
        agent_name: str = "ai-agent",
        auto_push: bool = True,
        commit_threshold: int = 5  # files changed
    ):
        self.repo_path = repo_path
        self.agent_name = agent_name
        self.auto_push = auto_push
        self.commit_threshold = commit_threshold
        self.changes_since_commit = 0
        self.current_task_files = []

    def _run_git(self, args: List[str]) -> Tuple[int, str, str]:
        """Run git command and return status, stdout, stderr."""
        cmd = ["git", "-C", self.repo_path] + args
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode, result.stdout, result.stderr

    def ensure_branch(self, branch_name: Optional[str] = None) -> str:
        """Create and checkout a branch for AI work."""
        if not branch_name:
            # Auto-generate branch name
            timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
            branch_name = f"ai/{self.agent_name}/{timestamp}"

        # Check if branch exists
        code, stdout, _ = self._run_git(["branch", "--list", branch_name])

        if branch_name not in stdout:
            # Create new branch
            self._run_git(["checkout", "-b", branch_name])
        else:
            # Checkout existing branch
            self._run_git(["checkout", branch_name])

        return branch_name

    def track_file_change(self, filepath: str, operation: str = "modified"):
        """Track that a file has been changed."""
        self.current_task_files.append({
            "file": filepath,
            "operation": operation,
            "timestamp": datetime.now().isoformat()
        })
        self.changes_since_commit += 1

        # Auto-commit if threshold reached
        if self.changes_since_commit >= self.commit_threshold:
            self.commit_current_work("Checkpoint: Multiple files updated")

    def commit_current_work(
        self,
        message: str,
        detailed_description: Optional[str] = None,
        task_type: Optional[str] = None
    ):
        """Commit current changes with structured message."""
        # Check if there are changes
        code, stdout, _ = self._run_git(["status", "--porcelain"])

        if not stdout.strip():
            return False

        # Stage all changes
        self._run_git(["add", "-A"])

        # Build commit message
        commit_parts = [f"[{self.agent_name}] {message}"]

        if detailed_description:
            commit_parts.append(f"\n\n{detailed_description}")

        if self.current_task_files:
            commit_parts.append("\n\nFiles changed:")
            for f in self.current_task_files:
                commit_parts.append(f"- {f['operation']}: {f['file']}")

        if task_type:
            commit_parts.append(f"\n\nTask type: {task_type}")

        commit_parts.append(f"\nAgent: {self.agent_name}")
        commit_parts.append(f"Timestamp: {datetime.now().isoformat()}")

        full_message = "\n".join(commit_parts)

        # Commit
        code, stdout, stderr = self._run_git(["commit", "-m", full_message])

        if code == 0:
            self.changes_since_commit = 0
            self.current_task_files = []

            # Auto-push if enabled
            if self.auto_push:
                self.push_changes()

            return True

        return False

    def push_changes(self):
        """Push commits to remote."""
        # Get current branch
        code, branch, _ = self._run_git(["branch", "--show-current"])
        branch = branch.strip()

        # Push, setting upstream if needed
        code, stdout, stderr = self._run_git(["push", "-u", "origin", branch])

        return code == 0

    def commit_checkpoint(self, context: Dict):
        """Commit at logical checkpoints based on context."""
        # Determine if this is a good checkpoint
        if context.get("task_completed"):
            self.commit_current_work(
                f"Completed: {context.get('task_name', 'task')}",
                detailed_description=context.get("description"),
                task_type=context.get("task_type")
            )
        elif context.get("milestone_reached"):
            self.commit_current_work(
                f"Milestone: {context.get('milestone_name', 'checkpoint')}",
                detailed_description=context.get("description")
            )
        elif context.get("error_fixed"):
            self.commit_current_work(
                f"Fixed: {context.get('error_description', 'error')}",
                detailed_description=context.get("solution")
            )