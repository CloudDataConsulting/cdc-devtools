#!/usr/bin/env bash
# AI Agent Project Template Setup
# Specialized configuration for AI/ML agent projects

# Template function called by create_project_session.sh
apply_template() {
    local session=$1
    local project_path=$2
    
    log_info "Applying ai-agent-project template"
    
    # The main window is already created and configured by the session creator
    # when AGENTS are defined in the config. We'll enhance it here.
    
    # If no agents were defined, set up a basic AI dev environment
    if [[ ${#AGENTS[@]} -eq 0 ]]; then
        # Window 0 (main): Development
        tmux send-keys -t "$session:0.0" "# AI Agent Development" C-m
        tmux send-keys -t "$session:0.0" "cd $project_path" C-m
        
        if [[ $PANE_COUNT -ge 2 ]]; then
            # Pane 1: Model monitoring
            tmux send-keys -t "$session:0.1" "# Model Monitoring Pane" C-m
            tmux send-keys -t "$session:0.1" "# Watch for model metrics, loss, accuracy" C-m
        fi
        
        if [[ $PANE_COUNT -ge 3 ]]; then
            # Pane 2: Agent logs
            tmux send-keys -t "$session:0.2" "# Agent Logs" C-m
            tmux send-keys -t "$session:0.2" "tail -f $project_path/logs/$(date +%Y-%m-%d)/*/session.log 2>/dev/null || echo 'Waiting for logs...'" C-m
        fi
    fi
    
    # Create directory structure for AI projects
    mkdir -p "$project_path"/{models,data,notebooks,tests/{unit,integration},logs}
    
    # Create a basic requirements.txt if it doesn't exist
    if [[ ! -f "$project_path/requirements.txt" ]]; then
        cat > "$project_path/requirements.txt" << 'EOF'
# AI/ML Dependencies
numpy>=1.21.0
pandas>=1.3.0
scikit-learn>=0.24.0
tensorflow>=2.6.0  # or pytorch>=1.9.0
jupyterlab>=3.0.0
matplotlib>=3.4.0
seaborn>=0.11.0
pytest>=6.2.0
python-dotenv>=0.19.0
EOF
    fi
    
    # Create basic project files if they don't exist
    if [[ ! -f "$project_path/README.md" ]]; then
        cat > "$project_path/README.md" << EOF
# $PROJECT_NAME

AI/ML project using CDC DevTools.

## Project Structure

- \`models/\` - Trained models and checkpoints
- \`data/\` - Training and evaluation data
- \`notebooks/\` - Jupyter notebooks for exploration
- \`tests/\` - Unit and integration tests
- \`logs/\` - Agent and training logs

## Getting Started

1. Install dependencies: \`pip install -r requirements.txt\`
2. Start Jupyter: \`jupyter lab --no-browser\`
3. Run tests: \`pytest tests/\`

## Agents

$(for agent in "${AGENTS[@]}"; do
    echo "- $(echo $agent | cut -d: -f2) (\`$(echo $agent | cut -d: -f1)\`)"
done)
EOF
    fi
    
    # Set up environment variables for AI projects
    if [[ -f "$project_path/.env" ]]; then
        tmux send-keys -t "$session:0.0" "source .env" C-m
    fi
    
    # If TensorBoard is enabled, prepare the command
    if [[ "$AI_ENABLE_TENSORBOARD" == "true" ]]; then
        log_info "TensorBoard enabled - run 'tensorboard --logdir=logs' to start"
    fi
    
    log_info "AI agent project template applied successfully"
}