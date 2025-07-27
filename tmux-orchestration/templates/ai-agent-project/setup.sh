#!/usr/bin/env bash
# AI Agent Project Template Setup
# Specialized configuration for AI/ML agent projects

# Template function called by create_project_session.sh
apply_template() {
    local session=$1
    local project_path=$2
    
    log_info "Applying ai-agent-project template"
    
    # Window 0 (main): Development
    tmux send-keys -t "$session:0.0" "# AI Agent Development" C-m
    tmux send-keys -t "$session:0.0" "cd $project_path" C-m
    
    # Pane 1: Model monitoring
    tmux send-keys -t "$session:0.1" "# Model Monitoring Pane" C-m
    tmux send-keys -t "$session:0.1" "# Watch for model metrics, loss, accuracy" C-m
    
    # Pane 2: Agent logs
    tmux send-keys -t "$session:0.2" "# Agent Logs" C-m
    tmux send-keys -t "$session:0.2" "tail -f logs/agent.log 2>/dev/null || echo 'Waiting for agent logs...'" C-m
    
    # Create training window
    tmux new-window -t "$session" -n "training" -c "$project_path"
    tmux send-keys -t "$session:training" "# Training Window" C-m
    tmux send-keys -t "$session:training" "# Use for model training: python train.py" C-m
    
    # Create jupyter window
    tmux new-window -t "$session" -n "jupyter" -c "$project_path"
    tmux send-keys -t "$session:jupyter" "# Jupyter Notebook Window" C-m
    tmux send-keys -t "$session:jupyter" "# Start with: jupyter lab --no-browser" C-m
    
    # Create testing window with splits
    tmux new-window -t "$session" -n "testing" -c "$project_path"
    tmux split-window -h -t "$session:testing"
    
    # Left: Unit tests
    tmux send-keys -t "$session:testing.0" "# Unit Tests" C-m
    tmux send-keys -t "$session:testing.0" "# Run: pytest tests/unit/" C-m
    
    # Right: Integration tests
    tmux send-keys -t "$session:testing.1" "# Integration Tests" C-m
    tmux send-keys -t "$session:testing.1" "# Run: pytest tests/integration/" C-m
    
    # Create monitoring dashboard window
    tmux new-window -t "$session" -n "metrics" -c "$project_path"
    tmux send-keys -t "$session:metrics" "# Metrics Dashboard" C-m
    tmux send-keys -t "$session:metrics" "# Start metrics server or tensorboard" C-m
    
    log_info "AI agent project template applied"
}