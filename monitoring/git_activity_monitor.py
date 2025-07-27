#!/usr/bin/env python3
"""Monitor git activity from AI agents."""

import subprocess
import json
from datetime import datetime, timedelta
from collections import defaultdict
import sys


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
    # Get days from command line or default to 7
    days = int(sys.argv[1]) if len(sys.argv) > 1 else 7
    
    stats = analyze_ai_commits(days=days)

    print("=== AI Agent Git Activity Report ===\n")
    print(f"Period: Last {stats['period_days']} days")
    print(f"Total AI Commits: {stats['total_commits']}\n")

    if stats['total_commits'] == 0:
        print("No AI agent commits found in this period.")
        print("\nAI commits are identified by:")
        print("- Commit messages containing 'Agent:'")
        print("- Commit messages with [agent-name] prefix")
        return

    print("Commits by Agent:")
    for agent, commits in stats['by_agent'].items():
        print(f"  {agent}: {len(commits)} commits")
        # Show recent commits
        for commit in commits[:3]:
            print(f"    - {commit['subject'][:60]}...")

    print("\nCommits by Type:")
    for commit_type, count in stats['by_type'].items():
        print(f"  {commit_type}: {count}")

    print("\nUsage:")
    print("  git ai-log        # View all AI commits")
    print("  git ai-stats      # View AI commit statistics")
    print("  cdc-git-monitor 30  # View last 30 days")


if __name__ == "__main__":
    main()