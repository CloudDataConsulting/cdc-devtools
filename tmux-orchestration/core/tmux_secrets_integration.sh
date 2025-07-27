#!/bin/bash
# Integration between tmux sessions and secrets management
# Allows each tmux window to have isolated secret contexts

# Source the logging framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging_framework.sh"

# ============================================================================
# Core Functions
# ============================================================================

# Create a tmux window with specific config context
create_window_with_config() {
    local window_name=$1
    local config_path=$2
    local startup_cmd=${3:-""}
    
    log "INFO" "Creating window '$window_name' with config: $config_path"
    
    # Create the window
    tmux new-window -n "$window_name"
    
    # Set window-specific environment to point to config
    tmux send-keys -t "$window_name" "export CDC_CONFIG_PATH='$config_path'" C-m
    
    # Show which config is active
    tmux send-keys -t "$window_name" "echo '📋 Using config: $config_path'" C-m
    tmux send-keys -t "$window_name" "echo '🔐 Secrets isolated to this window'" C-m
    tmux send-keys -t "$window_name" "echo ''" C-m
    
    # Run startup command if provided
    if [[ -n "$startup_cmd" ]]; then
        tmux send-keys -t "$window_name" "$startup_cmd" C-m
    fi
}

# Setup multi-account session with different configs per window
setup_multi_account_session() {
    local session_name=${1:-"multi-account"}
    
    log "INFO" "Setting up multi-account tmux session: $session_name"
    
    # Create session if it doesn't exist
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -d -s "$session_name"
    fi
    
    # Production window - uses prod config
    create_window_with_config "prod-deploy" "./configs/prod-config.yaml" \
        "echo 'Ready for production deployments'"
    
    # Terraform window - uses infra config  
    create_window_with_config "terraform" "./configs/infra-config.yaml" \
        "echo 'Terraform with dedicated backend credentials'"
    
    # Data pipeline window - uses data config
    create_window_with_config "data-etl" "./configs/data-config.yaml" \
        "echo 'ETL pipeline with data source credentials'"
    
    # Monitoring window - uses monitoring config
    create_window_with_config "monitoring" "./configs/monitoring-config.yaml" \
        "echo 'Monitoring with read-only credentials'"
    
    # Switch back to first window
    tmux select-window -t "$session_name:0"
    
    log "SUCCESS" "Multi-account session created successfully"
}

# Create window for specific AWS profile
create_aws_window() {
    local window_name=$1
    local aws_profile=$2
    local working_dir=${3:-"."}
    
    log "INFO" "Creating AWS window '$window_name' for profile: $aws_profile"
    
    tmux new-window -n "$window_name" -c "$working_dir"
    
    # Set up AWS profile-specific config
    tmux send-keys -t "$window_name" "# AWS Profile: $aws_profile" C-m
    tmux send-keys -t "$window_name" "export CDC_AWS_PROFILE='$aws_profile'" C-m
    
    # Create temporary config for this profile
    local temp_config="/tmp/cdc_config_${aws_profile}_$$.yaml"
    tmux send-keys -t "$window_name" "export CDC_CONFIG_PATH='$temp_config'" C-m
    
    # Show profile info
    tmux send-keys -t "$window_name" "echo '🔐 AWS Profile: $aws_profile'" C-m
    tmux send-keys -t "$window_name" "echo '📁 Working directory: $working_dir'" C-m
}

# Parse project config and create appropriate windows
setup_project_windows() {
    local config_file=${1:-".cdc-project.conf"}
    
    if [[ ! -f "$config_file" ]]; then
        log "ERROR" "Project config not found: $config_file"
        return 1
    fi
    
    log "INFO" "Setting up windows from project config: $config_file"
    
    # Source the config
    source "$config_file"
    
    # Check if we have tmux window configurations
    if [[ -n "${TMUX_WINDOWS[@]}" ]]; then
        for window_config in "${TMUX_WINDOWS[@]}"; do
            # Parse window configuration
            IFS='|' read -r name profile dir cmd <<< "$window_config"
            
            create_aws_window "$name" "$profile" "$dir"
            
            if [[ -n "$cmd" ]]; then
                tmux send-keys -t "$name" "$cmd" C-m
            fi
        done
    fi
    
    # Alternative: Check for secrets_configs in YAML-style config
    if [[ -n "${secrets_configs[@]}" ]]; then
        for window_name in "${!secrets_configs[@]}"; do
            local config_path="${secrets_configs[$window_name]}"
            create_window_with_config "$window_name" "$config_path"
        done
    fi
}

# Helper to show current config in any window
show_current_config() {
    if [[ -n "$CDC_CONFIG_PATH" ]]; then
        echo "📋 Current config: $CDC_CONFIG_PATH"
        
        # Show available secrets (without values)
        if command -v python3 &>/dev/null; then
            python3 -c "
import yaml
import os

config_path = os.environ.get('CDC_CONFIG_PATH', 'config.yaml')
try:
    with open(config_path) as f:
        config = yaml.safe_load(f)
    
    print('\nAvailable secrets:')
    secrets = config.get('secrets', {})
    for category, items in secrets.items():
        print(f'  {category}:')
        if isinstance(items, dict):
            for item in items:
                print(f'    - {item}')
except Exception as e:
    print(f'Error reading config: {e}')
"
        fi
    else
        echo "ℹ️  No specific config set for this window (using default)"
    fi
}

# ============================================================================
# Example Configurations
# ============================================================================

# Example: Development environment with multiple services
setup_dev_environment() {
    local project_name=${1:-"myproject"}
    
    log "INFO" "Setting up development environment for: $project_name"
    
    # API development window
    create_window_with_config "api" "./configs/api-dev.yaml" \
        "cd api && echo 'API server with dev database credentials'"
    
    # Frontend window
    create_window_with_config "frontend" "./configs/frontend-dev.yaml" \
        "cd frontend && echo 'Frontend with dev API keys'"
    
    # Database window
    create_window_with_config "database" "./configs/database-dev.yaml" \
        "echo 'Database tools with dev credentials'"
    
    # Testing window
    create_window_with_config "tests" "./configs/test-config.yaml" \
        "echo 'Test runner with test database'"
}

# Example: Multi-cloud deployment session
setup_multicloud_session() {
    log "INFO" "Setting up multi-cloud deployment session"
    
    # AWS deployment
    create_window_with_config "aws-deploy" "./configs/aws-prod.yaml" \
        "echo 'AWS deployment tools'"
    
    # GCP deployment
    create_window_with_config "gcp-deploy" "./configs/gcp-prod.yaml" \
        "echo 'GCP deployment tools'"
    
    # Azure deployment
    create_window_with_config "azure-deploy" "./configs/azure-prod.yaml" \
        "echo 'Azure deployment tools'"
    
    # Orchestrator
    create_window_with_config "orchestrator" "./configs/orchestrator.yaml" \
        "echo 'Multi-cloud orchestrator'"
}

# ============================================================================
# Utility Functions
# ============================================================================

# List all windows and their configs
list_window_configs() {
    echo "Current tmux windows and their configurations:"
    echo "=============================================="
    
    tmux list-windows -F "#{window_index}:#{window_name}" | while read -r window; do
        echo -n "Window $window: "
        
        # Try to get the CDC_CONFIG_PATH from the window
        config=$(tmux send-keys -t "$window" 'echo $CDC_CONFIG_PATH' C-m 2>/dev/null || echo "")
        
        if [[ -n "$config" ]]; then
            echo "Config: $config"
        else
            echo "No specific config"
        fi
    done
}

# Export current window's config path
export_config_path() {
    if [[ -n "$TMUX_PANE" ]]; then
        if [[ -n "$1" ]]; then
            export CDC_CONFIG_PATH="$1"
            echo "✅ Set config for this window: $CDC_CONFIG_PATH"
        else
            echo "Current config: ${CDC_CONFIG_PATH:-none}"
        fi
    else
        echo "❌ Not in a tmux session"
    fi
}

# ============================================================================
# Main execution
# ============================================================================

# If sourced, provide functions to the shell
# If executed, show help
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "CDC Tmux Secrets Integration"
    echo "============================"
    echo
    echo "This script provides functions for tmux windows with isolated secrets."
    echo
    echo "Usage:"
    echo "  source $0"
    echo
    echo "Then use:"
    echo "  setup_multi_account_session    - Create multi-account tmux session"
    echo "  setup_dev_environment          - Create development environment"
    echo "  setup_multicloud_session       - Create multi-cloud deployment session"
    echo "  create_window_with_config      - Create single window with config"
    echo "  show_current_config            - Show current window's config"
    echo "  list_window_configs            - List all windows and configs"
    echo
    echo "Example:"
    echo "  create_window_with_config 'prod' './configs/prod.yaml' 'python deploy.py'"
fi

# Add helper aliases when sourced
alias tmux-show-config='show_current_config'
alias tmux-set-config='export_config_path'