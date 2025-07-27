#!/usr/bin/env bash
# CDC Project Configuration Parser
# Reads and validates project configuration files

# Default configuration values
readonly DEFAULT_PROJECT_TYPE="basic-project"
readonly DEFAULT_LOG_LEVEL="INFO"
readonly DEFAULT_MONITORING_ENABLED="true"
readonly CONFIG_FILE_NAME=".cdc-project.conf"

# Parse project configuration file
parse_project_config() {
    local config_path=$1
    
    # Initialize default values
    PROJECT_NAME=""
    PROJECT_TYPE="$DEFAULT_PROJECT_TYPE"
    AGENTS=()
    MONITORING_ENABLED="$DEFAULT_MONITORING_ENABLED"
    LOG_LEVEL="$DEFAULT_LOG_LEVEL"
    CUSTOM_WINDOWS=()
    TMUX_LAYOUT="main-vertical"
    PANE_COUNT=3
    
    # Check if config file exists
    if [[ ! -f "$config_path" ]]; then
        return 1
    fi
    
    # Source the configuration file in a subshell to avoid pollution
    (
        # Define arrays that will be populated by config
        AGENTS=()
        CUSTOM_WINDOWS=()
        
        # Source the config
        source "$config_path"
        
        # Export parsed values
        echo "PROJECT_NAME='$PROJECT_NAME'"
        echo "PROJECT_TYPE='$PROJECT_TYPE'"
        echo "MONITORING_ENABLED='$MONITORING_ENABLED'"
        echo "LOG_LEVEL='$LOG_LEVEL'"
        echo "TMUX_LAYOUT='$TMUX_LAYOUT'"
        echo "PANE_COUNT='$PANE_COUNT'"
        
        # Export arrays
        echo "AGENTS=("
        for agent in "${AGENTS[@]}"; do
            echo "  '$agent'"
        done
        echo ")"
        
        echo "CUSTOM_WINDOWS=("
        for window in "${CUSTOM_WINDOWS[@]}"; do
            echo "  '$window'"
        done
        echo ")"
    ) > /tmp/cdc_config_$$
    
    # Source the exported values
    source /tmp/cdc_config_$$
    rm -f /tmp/cdc_config_$$
    
    return 0
}

# Validate configuration
validate_config() {
    local errors=()
    
    # Check required fields
    if [[ -z "$PROJECT_NAME" ]]; then
        errors+=("PROJECT_NAME is required")
    fi
    
    # Validate project type
    local valid_types=("basic-project" "ai-agent-project" "data-pipeline" "api-service" "snowflake-project")
    if [[ ! " ${valid_types[@]} " =~ " ${PROJECT_TYPE} " ]]; then
        errors+=("Invalid PROJECT_TYPE: $PROJECT_TYPE")
    fi
    
    # Validate log level
    local valid_levels=("DEBUG" "INFO" "WARN" "ERROR")
    if [[ ! " ${valid_levels[@]} " =~ " ${LOG_LEVEL} " ]]; then
        errors+=("Invalid LOG_LEVEL: $LOG_LEVEL")
    fi
    
    # Validate boolean values
    if [[ "$MONITORING_ENABLED" != "true" && "$MONITORING_ENABLED" != "false" ]]; then
        errors+=("MONITORING_ENABLED must be 'true' or 'false'")
    fi
    
    # Validate tmux layout
    local valid_layouts=("even-horizontal" "even-vertical" "main-horizontal" "main-vertical" "tiled")
    if [[ ! " ${valid_layouts[@]} " =~ " ${TMUX_LAYOUT} " ]]; then
        errors+=("Invalid TMUX_LAYOUT: $TMUX_LAYOUT")
    fi
    
    # Validate pane count
    if ! [[ "$PANE_COUNT" =~ ^[0-9]+$ ]] || [[ "$PANE_COUNT" -lt 1 ]] || [[ "$PANE_COUNT" -gt 10 ]]; then
        errors+=("PANE_COUNT must be between 1 and 10")
    fi
    
    # Return errors
    if [[ ${#errors[@]} -gt 0 ]]; then
        printf '%s\n' "${errors[@]}"
        return 1
    fi
    
    return 0
}

# Create default configuration file
create_default_config() {
    local project_path=$1
    local project_name=$2
    local project_type=${3:-$DEFAULT_PROJECT_TYPE}
    
    cat > "$project_path/$CONFIG_FILE_NAME" << EOF
# CDC Project Configuration
# Project: $project_name
# Generated: $(date)

# Basic Information
PROJECT_NAME="$project_name"
PROJECT_TYPE="$project_type"

# Logging Configuration
LOG_LEVEL="INFO"
MONITORING_ENABLED=true

# Tmux Configuration
TMUX_LAYOUT="main-vertical"
PANE_COUNT=3

# AI Agent Configuration (for ai-agent-project type)
# AGENTS=(
#     "orchestrator:Main Orchestrator"
#     "data:Data Processing Agent"
#     "api:API Integration Agent"
# )

# Custom Windows (optional)
# CUSTOM_WINDOWS=(
#     "database:Database Operations"
#     "testing:Test Runner"
# )

# Project-specific settings
# Add your custom configuration here
EOF
}

# Get config value with default
get_config_value() {
    local key=$1
    local default=$2
    local value="${!key}"
    
    if [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Export functions
export -f parse_project_config validate_config create_default_config get_config_value