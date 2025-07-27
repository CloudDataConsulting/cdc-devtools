#!/usr/bin/env python3
"""Generate summary report from project logs."""

import os
import json
import re
from datetime import datetime
from pathlib import Path
from collections import defaultdict
import argparse

def parse_logs(log_dir):
    """Parse all agent logs for the day."""
    summary = {
        "date": os.path.basename(log_dir),
        "project": os.environ.get("CDC_PROJECT_NAME", "Unknown"),
        "agents": defaultdict(dict),
        "tasks_completed": [],
        "errors": [],
        "decisions": [],
        "files_changed": []
    }
    
    for agent_dir in Path(log_dir).iterdir():
        if agent_dir.is_dir():
            agent_name = agent_dir.name
            session_log = agent_dir / "session.log"
            
            if session_log.exists():
                with open(session_log, 'r') as f:
                    content = f.read()
                    
                    # Extract key information
                    summary["agents"][agent_name] = {
                        "start_time": extract_start_time(content),
                        "tasks": extract_tasks(content),
                        "errors": extract_errors(content),
                        "files": extract_files(content),
                        "line_count": len(content.splitlines())
                    }
    
    # Look for decision logs
    decisions_dir = Path(log_dir).parent / "decisions"
    if decisions_dir.exists():
        for decision_file in decisions_dir.glob("*.md"):
            if decision_file.name != "TEMPLATE.md":
                summary["decisions"].append(decision_file.name)
    
    return summary

def extract_start_time(content):
    """Extract agent start time from log."""
    # Look for various start patterns
    patterns = [
        r'Started at (.+)',
        r'Agent Started at (.+)',
        r'Session started: (.+)',
        r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\].*?(started|initialized)'
    ]
    
    for pattern in patterns:
        match = re.search(pattern, content, re.IGNORECASE)
        if match:
            return match.group(1)
    
    # If no explicit start time, get first timestamp
    timestamp_match = re.search(r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]', content)
    return timestamp_match.group(1) if timestamp_match else "Unknown"

def extract_tasks(content):
    """Extract completed tasks from log."""
    # Look for various task completion patterns
    task_patterns = [
        r'✅ (.+)',
        r'✓ (.+)',
        r'\[COMPLETED\] (.+)',
        r'Task completed: (.+)',
        r'Successfully (.+)',
        r'Finished (.+)'
    ]
    
    tasks = []
    for pattern in task_patterns:
        tasks.extend(re.findall(pattern, content))
    
    return list(set(tasks))  # Remove duplicates

def extract_errors(content):
    """Extract errors from log."""
    error_patterns = [
        r'❌ (.+)',
        r'✗ (.+)',
        r'\[ERROR\] (.+)',
        r'Error: (.+)',
        r'Failed to (.+)',
        r'Exception: (.+)'
    ]
    
    errors = []
    for pattern in error_patterns:
        errors.extend(re.findall(pattern, content))
    
    return list(set(errors))  # Remove duplicates

def extract_files(content):
    """Extract file changes from log."""
    file_patterns = [
        r'(?:Created|Modified|Updated|Deleted): (.+)',
        r'File (?:created|modified|updated|deleted): (.+)',
        r'Writing to: (.+)',
        r'Saved: (.+)',
        r'Generated: (.+)'
    ]
    
    files = []
    for pattern in file_patterns:
        files.extend(re.findall(pattern, content, re.IGNORECASE))
    
    return list(set(files))  # Remove duplicates

def generate_markdown_report(summary):
    """Generate a markdown summary report."""
    report = f"""# Work Summary - {summary['project']} - {summary['date']}

## 📊 Overview

| Component | Start Time | Tasks | Errors | Lines Logged |
|-----------|------------|-------|--------|--------------|
"""
    
    total_tasks = 0
    total_errors = 0
    total_lines = 0
    
    for agent, data in summary['agents'].items():
        task_count = len(data.get('tasks', []))
        error_count = len(data.get('errors', []))
        line_count = data.get('line_count', 0)
        
        total_tasks += task_count
        total_errors += error_count
        total_lines += line_count
        
        report += f"| {agent} | {data['start_time']} | {task_count} | {error_count} | {line_count} |\n"
    
    report += f"| **TOTAL** | - | **{total_tasks}** | **{total_errors}** | **{total_lines}** |\n"
    
    # Add completed tasks section
    if total_tasks > 0:
        report += "\n## ✅ Completed Tasks\n"
        for agent, data in summary['agents'].items():
            if data.get('tasks'):
                report += f"\n### {agent}\n"
                for task in data['tasks']:
                    report += f"- {task}\n"
    
    # Add errors section
    if total_errors > 0:
        report += "\n## ❌ Errors Encountered\n"
        for agent, data in summary['agents'].items():
            if data.get('errors'):
                report += f"\n### {agent}\n"
                for error in data['errors']:
                    report += f"- {error}\n"
    
    # Add files changed section
    all_files = []
    for agent, data in summary['agents'].items():
        all_files.extend(data.get('files', []))
    
    if all_files:
        report += "\n## 📝 Files Changed\n"
        for file in sorted(set(all_files)):
            report += f"- {file}\n"
    
    # Add decisions section
    if summary.get('decisions'):
        report += "\n## 🤔 Decisions Logged\n"
        for decision in summary['decisions']:
            report += f"- {decision}\n"
    
    report += f"\n---\n*Generated at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*"
    
    return report

def main():
    parser = argparse.ArgumentParser(description='Generate summary report from project logs')
    parser.add_argument('log_dir', nargs='?', help='Log directory to analyze')
    parser.add_argument('-p', '--project', help='Project root directory')
    parser.add_argument('-o', '--output', help='Output file path')
    parser.add_argument('--json', action='store_true', help='Output JSON instead of markdown')
    
    args = parser.parse_args()
    
    # Determine log directory
    if args.log_dir:
        log_dir = args.log_dir
    elif args.project:
        log_dir = os.path.join(args.project, 'logs', datetime.now().strftime('%Y-%m-%d'))
    else:
        # Try to use CDC_PROJECT_PATH environment variable
        project_path = os.environ.get('CDC_PROJECT_PATH', os.getcwd())
        log_dir = os.path.join(project_path, 'logs', datetime.now().strftime('%Y-%m-%d'))
    
    if not os.path.exists(log_dir):
        print(f"Error: Log directory not found: {log_dir}")
        return 1
    
    # Parse logs
    summary = parse_logs(log_dir)
    
    # Generate output
    if args.json:
        output = json.dumps(summary, indent=2)
    else:
        output = generate_markdown_report(summary)
    
    # Write output
    if args.output:
        output_file = args.output
    else:
        # Default output location
        summary_dir = Path(log_dir).parent / "summaries"
        summary_dir.mkdir(exist_ok=True)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        ext = 'json' if args.json else 'md'
        output_file = summary_dir / f"{os.path.basename(log_dir)}_summary_{timestamp}.{ext}"
    
    with open(output_file, 'w') as f:
        f.write(output)
    
    print(f"Summary report generated: {output_file}")
    
    # Also print to stdout if not saving to default location
    if args.output:
        print("\n" + output)

if __name__ == "__main__":
    main()