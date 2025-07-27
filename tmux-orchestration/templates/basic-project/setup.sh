#!/usr/bin/env bash
# Basic Project Template Setup
# Standard configuration for general CDC projects

# Template function called by create_project_session.sh
apply_template() {
    local session=$1
    local project_path=$2
    
    log_info "Applying basic-project template"
    
    # Window 0 (main): Editor and shell
    tmux send-keys -t "$session:0.0" "# Main development pane" C-m
    tmux send-keys -t "$session:0.0" "cd $project_path" C-m
    
    # Pane 1: Git status monitoring
    tmux send-keys -t "$session:0.1" "watch -n 5 'git status -sb && echo && git log --oneline -5'" C-m
    
    # Pane 2: Test runner / Build watcher
    tmux send-keys -t "$session:0.2" "# Test/Build pane - configure for your project" C-m
    tmux send-keys -t "$session:0.2" "# Examples: npm test --watch, pytest --watch, cargo watch" C-m
    
    # Create additional windows
    tmux new-window -t "$session" -n "terminal" -c "$project_path"
    tmux new-window -t "$session" -n "logs" -c "$project_path"
    
    # Set up log window
    tmux send-keys -t "$session:logs" "tail -f $CDC_LOG_DIR/cdc-*.log | grep $session" C-m
    
    log_info "Basic project template applied"
}