# Add Automated Git Workflow to CDC DevTools

Implement automated git commit/push functionality for AI agents to maintain granular history of all work.

## 1. Create Git Automation Module

Create `ai-agents/base-agents/git_manager.py`:

```python
"""
Automated git operations for AI agents.
Commits and pushes work automatically at logical checkpoints.
"""

import subprocess
import os
from datetime import datetime
from typing import List, Optional, Dict
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

    def _run_git(self, args: List[str]) -> tuple[int, str, str]:
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
```

## 2. Create Commit Strategy Configuration

Create `ai-agents/config/git_strategy.yaml`:

```yaml
# Git automation strategy for CDC AI Agents
git_automation:
  # Global settings
  auto_commit: true
  auto_push: true
  default_branch_prefix: "ai"

  # When to commit automatically
  commit_triggers:
    - files_changed: 5  # After 5 files modified
    - lines_changed: 500  # After 500 lines changed
    - time_elapsed: 1800  # After 30 minutes
    - task_completed: true  # After each task
    - test_passed: true  # After tests pass
    - error_resolved: true  # After fixing an error

  # Commit message templates
  message_templates:
    feature: "[{agent}] Add {feature_name}"
    bugfix: "[{agent}] Fix {issue_description}"
    refactor: "[{agent}] Refactor {component}"
    test: "[{agent}] Add tests for {component}"
    docs: "[{agent}] Update documentation for {component}"
    checkpoint: "[{agent}] Checkpoint: {description}"

  # Branch naming strategies
  branch_strategies:
    orchestrator:
      pattern: "ai/orchestration/{date}-{task}"
      auto_create: true
    feature_agent:
      pattern: "ai/feature/{feature_name}"
      auto_create: true
    bugfix_agent:
      pattern: "ai/fix/{issue_id}"
      auto_create: true
    exploration:
      pattern: "ai/explore/{description}"
      auto_create: true
```

## 3. Create Git-Aware Base Agent

Create `ai-agents/base-agents/git_aware_agent.py`:

```python
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
```

## 4. Create Git Hooks for AI Commits

Create `git-hooks/prepare-commit-msg`:

```bash
#!/bin/bash
# Add AI agent metadata to commit messages

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Only process AI agent commits
if grep -q "\[ai-" "$COMMIT_MSG_FILE" || grep -q "Agent:" "$COMMIT_MSG_FILE"; then
    # Add metadata
    echo "" >> "$COMMIT_MSG_FILE"
    echo "# AI Commit Metadata" >> "$COMMIT_MSG_FILE"
    echo "# Generated at: $(date -u +"%Y-%m-%d %H:%M:%S UTC")" >> "$COMMIT_MSG_FILE"
    echo "# Working directory: $(pwd)" >> "$COMMIT_MSG_FILE"

    # Add change statistics
    echo "# Changes:" >> "$COMMIT_MSG_FILE"
    git diff --cached --stat | sed 's/^/# /' >> "$COMMIT_MSG_FILE"
fi
```

## 5. Create Monitoring for Git Activity

Create `monitoring/git_activity_monitor.py`:

```python
#!/usr/bin/env python3
"""Monitor git activity from AI agents."""

import subprocess
import json
from datetime import datetime, timedelta
from collections import defaultdict


def analyze_ai_commits(repo_path=".", days=7):
    """Analyze AI agent git activity."""

    # Get commits from last N days
    since_date = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")

    cmd = [
        "git", "-C", repo_path, "log",
        f"--since={since_date}",
        "--grep=Agent:",
        "--pretty=format:%H|%an|%ai|%s|%b",
        "--no-merges"
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    agent_commits = defaultdict(list)
    commit_types = defaultdict(int)

    for line in result.stdout.strip().split('\n'):
        if not line:
            continue

        parts = line.split('|', 4)
        if len(parts) < 5:
            continue

        hash, author, date, subject, body = parts

        # Extract agent name
        if "[" in subject and "]" in subject:
            agent = subject[subject.find("[")+1:subject.find("]")]
            agent_commits[agent].append({
                "hash": hash,
                "date": date,
                "subject": subject,
                "type": categorize_commit(subject)
            })

            commit_types[categorize_commit(subject)] += 1

    return {
        "total_commits": sum(len(commits) for commits in agent_commits.values()),
        "by_agent": dict(agent_commits),
        "by_type": dict(commit_types),
        "period_days": days
    }


def categorize_commit(subject):
    """Categorize commit by type."""
    subject_lower = subject.lower()

    if any(word in subject_lower for word in ["fix", "bug", "error"]):
        return "bugfix"
    elif any(word in subject_lower for word in ["add", "feature", "implement"]):
        return "feature"
    elif any(word in subject_lower for word in ["test"]):
        return "test"
    elif any(word in subject_lower for word in ["refactor", "improve"]):
        return "refactor"
    elif any(word in subject_lower for word in ["doc", "readme"]):
        return "docs"
    elif any(word in subject_lower for word in ["checkpoint", "progress"]):
        return "checkpoint"
    else:
        return "other"


def main():
    """Generate git activity report."""
    stats = analyze_ai_commits()

    print("=== AI Agent Git Activity Report ===\n")
    print(f"Period: Last {stats['period_days']} days")
    print(f"Total AI Commits: {stats['total_commits']}\n")

    print("Commits by Agent:")
    for agent, commits in stats['by_agent'].items():
        print(f"  {agent}: {len(commits)} commits")
        # Show recent commits
        for commit in commits[:3]:
            print(f"    - {commit['subject'][:60]}...")

    print("\nCommits by Type:")
    for commit_type, count in stats['by_type'].items():
        print(f"  {commit_type}: {count}")


if __name__ == "__main__":
    main()
```

## 6. Create Integration Example

Create `ai-agents/examples/auto_commit_agent.py`:

```python
"""Example agent with automatic git commits."""

from ai_agents.base_agents.git_aware_agent import GitAwareAgent
from ai_agents.base_agents.model_aware_agent import ModelAwareAgent


class AutoCommitAgent(GitAwareAgent, ModelAwareAgent):
    """Agent that combines model routing with auto-commits."""

    def __init__(self):
        GitAwareAgent.__init__(self, "auto-commit-agent")
        ModelAwareAgent.__init__(self, "auto-commit-agent")

    def process_feature(self, feature_request):
        """Process a feature request with automatic commits."""

        # Create feature branch
        branch = self.git.ensure_branch(f"ai/feature/{feature_request['name']}")

        # Design phase
        design = self.execute_with_model(
            task_type="system_design",
            description=f"Design {feature_request['name']}",
            task_fn=lambda model: self._create_design(feature_request, model)
        )
        self.complete_task("Design Complete", f"Created design for {feature_request['name']}")

        # Implementation phase
        for component in design['components']:
            code = self._implement_component(component)
            self.git.track_file_change(f"src/{component['name']}.py", "created")

        self.complete_task("Implementation Complete", "All components implemented")

        # Testing phase
        tests = self._create_tests(design)
        for test_file in tests:
            self.git.track_file_change(test_file, "created")

        self.complete_task("Tests Added", "Test suite complete")

        # Final push
        self.git.push_changes()

        return {
            "branch": branch,
            "commits": len(self.git.current_task_files),
            "status": "complete"
        }
```

## 7. Add Installation Script

Update `team-setup/onboard_developer.sh` to include git hooks:

```bash
# Install git hooks for AI tracking
echo "Installing git hooks..."
cp $CDC_DEVTOOLS/git-hooks/* .git/hooks/
chmod +x .git/hooks/*

# Configure git for AI commits
git config --global alias.ai-log "log --grep='Agent:' --pretty=format:'%h %ai %s' --no-merges"
git config --global alias.ai-stats "shortlog -sn --grep='Agent:' --no-merges"
```

## 8. Update Documentation

Add to main README.md:

```markdown
## Automated Git Workflow

AI agents automatically commit and push their work:

- **Auto-commits** after logical checkpoints
- **Smart branching** for different types of work
- **Detailed commit messages** with context
- **Activity monitoring** to track AI contributions

### View AI Commits

```bash
# See all AI commits
git ai-log

# See AI commit statistics
git ai-stats

# Monitor AI git activity
cdc-git-monitor
```

### Configuration

Agents inherit from `GitAwareAgent` to get automatic commits:

```python
class MyAgent(GitAwareAgent):
    def process_task(self, task):
        # ... do work ...
        self.complete_task("Task Done", "Description")
        # Automatically commits and pushes!
```
```

This system will give you complete traceability of all AI work with meaningful commits at logical checkpoints!
