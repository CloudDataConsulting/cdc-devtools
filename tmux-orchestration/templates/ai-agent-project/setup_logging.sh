#!/usr/bin/env bash
# AI Agent Logging Setup Script
# Generalized version for any CDC project with AI agents

# Source the logging framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../core/logging_framework.sh"

# Function to setup AI agent logging
setup_ai_logging() {
    local project_root=$1
    local project_name=$2
    local -a agents=("${!3}")  # Array of agents passed by reference
    
    log_info "Setting up AI Agent Logging System for $project_name"
    
    DATE=$(date +%Y-%m-%d)
    TIME=$(date +%H-%M-%S)
    
    # Create logging directory structure
    log_info "Creating logging directories..."
    mkdir -p "$project_root/logs/$DATE"
    mkdir -p "$project_root/logs/decisions"
    mkdir -p "$project_root/logs/summaries"
    mkdir -p "$project_root/logs/git-commits"
    
    # Create agent-specific log directories
    for agent in "${agents[@]}"; do
        agent_dir=$(echo "$agent" | cut -d: -f1)
        mkdir -p "$project_root/logs/$DATE/$agent_dir"
    done
    
    # Create logging configuration file
    cat > "$project_root/logs/logging.conf" << EOF
# AI Agent Logging Configuration
# Project: $project_name
# Generated: $(date)

LOG_LEVEL=INFO
LOG_FORMAT="[%(timestamp)s] [%(agent)s] [%(level)s] %(message)s"
DECISION_TRACKING=true
GIT_COMMIT_TRACKING=true
PERFORMANCE_TRACKING=true
PROJECT_NAME=$project_name
PROJECT_ROOT=$project_root
EOF
    
    # Create decision logging template
    create_decision_template "$project_root"
    
    # Set up git hooks if in a git repo
    if [[ -d "$project_root/.git" ]]; then
        setup_git_hooks "$project_root"
    fi
    
    log_info "AI logging system setup complete for $project_name"
}

# Create decision logging template
create_decision_template() {
    local project_root=$1
    
    cat > "$project_root/logs/decisions/TEMPLATE.md" << 'EOF'
# AI Agent Decision Log

**Date**: YYYY-MM-DD HH:MM:SS
**Agent**: [Agent Name]
**Task**: [Task Description]
**Session**: [Session ID]

## Context
[What problem or task was the agent addressing?]

## Analysis
[How did the agent understand the problem?]

## Options Considered
1. **Option A**: [Description]
   - Pros: [List pros]
   - Cons: [List cons]
2. **Option B**: [Description]
   - Pros: [List pros]
   - Cons: [List cons]

## Decision
[What approach was chosen and why?]

## Implementation
[Key steps taken]

## Results
[What was accomplished?]

## Lessons Learned
[What worked well? What could be improved?]

## Code Changes
- Files created: [List]
- Files modified: [List]
- Tests added: [List]
EOF
}

# Setup git hooks for commit tracking
setup_git_hooks() {
    local project_root=$1
    
    cat > "$project_root/.git/hooks/post-commit" << 'EOF'
#!/bin/bash
# Log AI agent commits

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
DATE=$(date +%Y-%m-%d)
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B)
AUTHOR=$(git log -1 --pretty=%an)

# Create log directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/logs/git-commits"

# Log the commit
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] [$AUTHOR] $COMMIT_HASH: $COMMIT_MSG" >> "$PROJECT_ROOT/logs/git-commits/$DATE.log"
EOF
    
    chmod +x "$project_root/.git/hooks/post-commit"
}

# Export functions for use in other scripts
export -f setup_ai_logging create_decision_template setup_git_hooks