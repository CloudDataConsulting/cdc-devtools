#!/usr/bin/env bash
# CDC Project Session Creator v2
# Creates standardized tmux sessions with configuration file support

# Source required modules
# Handle both direct execution and symlink execution
if [[ -L "${BASH_SOURCE[0]}" ]]; then
    # If it's a symlink, resolve it
    SCRIPT_PATH="$(readlink "${BASH_SOURCE[0]}")"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd "$(dirname "$SCRIPT_PATH")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

source "$SCRIPT_DIR/logging_framework.sh"
source "$SCRIPT_DIR/config_parser.sh"

# Default configuration
readonly DEFAULT_LAYOUT="main-vertical"
readonly DEFAULT_PANES=3

# Usage function
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] SESSION_NAME PROJECT_PATH

Creates a standardized tmux session for CDC projects with logging enabled.
Automatically detects and uses .cdc-project.conf if present.

OPTIONS:
    -l LAYOUT     Tmux layout (default: from config or main-vertical)
    -p PANES      Number of panes (default: from config or 3)
    -t TEMPLATE   Use template from templates/ directory
    -c CONFIG     Path to custom config file
    -g            Generate config file if missing
    -h            Show this help message

EXAMPLES:
    $(basename "$0") myproject ~/repos/myproject
    $(basename "$0") -g aibot ~/repos/aibot              # Generate config
    $(basename "$0") -t ai-agent-project aibot ~/repos/aibot
    $(basename "$0") -c custom.conf analytics ~/repos/analytics

EOF
    exit 1
}

# Parse command line options
parse_options() {
    local OPTIND
    LAYOUT=""
    PANES=""
    TEMPLATE=""
    CONFIG_FILE=""
    GENERATE_CONFIG=false
    
    while getopts "l:p:t:c:gh" opt; do
        case $opt in
            l) LAYOUT=$OPTARG ;;
            p) PANES=$OPTARG ;;
            t) TEMPLATE=$OPTARG ;;
            c) CONFIG_FILE=$OPTARG ;;
            g) GENERATE_CONFIG=true ;;
            h) usage ;;
            *) usage ;;
        esac
    done
    
    shift $((OPTIND-1))
    
    if [[ $# -ne 2 ]]; then
        log_error "Invalid number of arguments"
        usage
    fi
    
    SESSION_NAME=$1
    PROJECT_PATH=$2
}

# Load project configuration
load_project_config() {
    local config_path=""
    
    # Determine config path
    if [[ -n "$CONFIG_FILE" ]]; then
        config_path="$CONFIG_FILE"
    else
        config_path="$PROJECT_PATH/.cdc-project.conf"
    fi
    
    # Generate config if requested
    if $GENERATE_CONFIG && [[ ! -f "$config_path" ]]; then
        log_info "Generating project configuration file"
        local project_type="${TEMPLATE:-basic-project}"
        create_default_config "$PROJECT_PATH" "$SESSION_NAME" "$project_type"
        log_info "Created $config_path"
    fi
    
    # Load config if exists
    if [[ -f "$config_path" ]]; then
        log_info "Loading configuration from $config_path"
        if parse_project_config "$config_path"; then
            # Validate configuration
            local validation_errors=$(validate_config)
            if [[ -n "$validation_errors" ]]; then
                log_error "Configuration validation failed:"
                echo "$validation_errors"
                exit 1
            fi
            
            # Override with command line options if provided
            LAYOUT=${LAYOUT:-$TMUX_LAYOUT}
            PANES=${PANES:-$PANE_COUNT}
            TEMPLATE=${TEMPLATE:-$PROJECT_TYPE}
        else
            log_warn "Failed to parse configuration file"
        fi
    else
        log_info "No configuration file found, using defaults"
        # Set defaults if not overridden
        LAYOUT=${LAYOUT:-$DEFAULT_LAYOUT}
        PANES=${PANES:-$DEFAULT_PANES}
        PROJECT_NAME=${PROJECT_NAME:-$SESSION_NAME}
        PROJECT_TYPE=${TEMPLATE:-"basic-project"}
        MONITORING_ENABLED="true"
        LOG_LEVEL="INFO"
    fi
}

# Validate inputs
validate_inputs() {
    # Check if session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "Session '$SESSION_NAME' already exists"
        exit 1
    fi
    
    # Check if project path exists
    if [[ ! -d "$PROJECT_PATH" ]]; then
        log_error "Project path '$PROJECT_PATH' does not exist"
        exit 1
    fi
    
    # Validate template if specified
    if [[ -n "$TEMPLATE" ]]; then
        TEMPLATE_PATH="$SCRIPT_DIR/../templates/$TEMPLATE/setup.sh"
        if [[ ! -f "$TEMPLATE_PATH" ]]; then
            log_error "Template '$TEMPLATE' not found"
            exit 1
        fi
    fi
}

# Create tmux session with AI agent support
create_ai_session() {
    log_info "Creating AI agent session with ${#AGENTS[@]} agents"
    
    # Source AI logging setup
    source "$SCRIPT_DIR/../templates/ai-agent-project/setup_logging.sh"
    setup_ai_logging "$PROJECT_PATH" "$PROJECT_NAME" AGENTS[@]
    
    # Create window for each agent
    local first_window=true
    for agent_spec in "${AGENTS[@]}"; do
        local agent_id=$(echo "$agent_spec" | cut -d: -f1)
        local agent_name=$(echo "$agent_spec" | cut -d: -f2)
        
        if $first_window; then
            # Rename first window
            tmux rename-window -t "$SESSION_NAME:0" "$agent_id"
            first_window=false
        else
            # Create new window
            tmux new-window -t "$SESSION_NAME" -n "$agent_id" -c "$PROJECT_PATH"
        fi
        
        # Set up agent window
        tmux send-keys -t "$SESSION_NAME:$agent_id" "echo '🤖 $agent_name Started at $(date)'" C-m
        tmux send-keys -t "$SESSION_NAME:$agent_id" "export CDC_AGENT_ID='$agent_id'" C-m
        tmux send-keys -t "$SESSION_NAME:$agent_id" "export CDC_AGENT_NAME='$agent_name'" C-m
        
        # Enable logging for this pane
        local log_file="$PROJECT_PATH/logs/$(date +%Y-%m-%d)/$agent_id/session.log"
        mkdir -p "$(dirname "$log_file")"
        tmux pipe-pane -t "$SESSION_NAME:$agent_id" -o "cat >> $log_file"
    done
    
    # Create orchestrator monitoring pane if we have multiple agents
    if [[ ${#AGENTS[@]} -gt 1 ]]; then
        tmux select-window -t "$SESSION_NAME:0"
        tmux split-window -t "$SESSION_NAME:0" -h
        tmux send-keys -t "$SESSION_NAME:0.1" "tail -f $PROJECT_PATH/logs/$(date +%Y-%m-%d)/*/session.log" C-m
    fi
}

# Create tmux session
create_session() {
    log_info "Creating tmux session: $SESSION_NAME"
    
    # Start logging session
    start_log_session "$SESSION_NAME"
    
    # Export project environment
    export CDC_SESSION_NAME="$SESSION_NAME"
    export CDC_PROJECT_PATH="$PROJECT_PATH"
    export CDC_PROJECT_NAME="$PROJECT_NAME"
    export CDC_LOG_LEVEL="$LOG_LEVEL"
    
    # Create new session with first window
    tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_PATH" -n "main"
    
    # Set up environment variables in session
    tmux send-keys -t "$SESSION_NAME:0" "export CDC_SESSION_NAME='$SESSION_NAME'" C-m
    tmux send-keys -t "$SESSION_NAME:0" "export CDC_PROJECT_PATH='$PROJECT_PATH'" C-m
    tmux send-keys -t "$SESSION_NAME:0" "export CDC_PROJECT_NAME='$PROJECT_NAME'" C-m
    tmux send-keys -t "$SESSION_NAME:0" "export CDC_LOG_DIR='$CDC_LOG_DIR'" C-m
    tmux send-keys -t "$SESSION_NAME:0" "export CDC_LOG_LEVEL='$LOG_LEVEL'" C-m
    
    # Source logging framework in main pane
    tmux send-keys -t "$SESSION_NAME:0" "source $SCRIPT_DIR/logging_framework.sh" C-m
    
    # Handle AI agent projects specially
    if [[ "$PROJECT_TYPE" == "ai-agent-project" ]] && [[ ${#AGENTS[@]} -gt 0 ]]; then
        create_ai_session
    else
        # Standard session creation
        # Create additional panes
        for ((i=1; i<$PANES; i++)); do
            tmux split-window -t "$SESSION_NAME:0" -c "$PROJECT_PATH"
            tmux send-keys -t "$SESSION_NAME:0.$i" "source $SCRIPT_DIR/logging_framework.sh" C-m
        done
        
        # Apply layout
        tmux select-layout -t "$SESSION_NAME:0" "$LAYOUT"
    fi
    
    # Apply template if specified
    if [[ -n "$TEMPLATE_PATH" ]]; then
        log_info "Applying template: $TEMPLATE"
        source "$TEMPLATE_PATH"
        apply_template "$SESSION_NAME" "$PROJECT_PATH"
    fi
    
    # Create custom windows if specified
    for window_spec in "${CUSTOM_WINDOWS[@]}"; do
        local window_id=$(echo "$window_spec" | cut -d: -f1)
        local window_name=$(echo "$window_spec" | cut -d: -f2)
        
        tmux new-window -t "$SESSION_NAME" -n "$window_id" -c "$PROJECT_PATH"
        tmux send-keys -t "$SESSION_NAME:$window_id" "# $window_name" C-m
        tmux send-keys -t "$SESSION_NAME:$window_id" "source $SCRIPT_DIR/logging_framework.sh" C-m
    done
    
    # Create monitoring window if enabled
    if [[ "$MONITORING_ENABLED" == "true" ]]; then
        create_monitoring_window
    fi
    
    # Select main window and first pane
    tmux select-window -t "$SESSION_NAME:0"
    tmux select-pane -t "$SESSION_NAME:0.0"
    
    log_info "Session '$SESSION_NAME' created successfully"
}

# Create monitoring window
create_monitoring_window() {
    log_info "Creating monitoring window"
    
    tmux new-window -t "$SESSION_NAME" -n "monitor" -c "$PROJECT_PATH"
    
    # Set up monitoring in the window
    tmux send-keys -t "$SESSION_NAME:monitor" "# Monitoring window for $SESSION_NAME" C-m
    tmux send-keys -t "$SESSION_NAME:monitor" "$SCRIPT_DIR/../../monitoring/monitor_project.sh" C-m
}

# Attach to session
attach_session() {
    log_info "Attaching to session: $SESSION_NAME"
    
    # Check if already in tmux
    if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$SESSION_NAME"
    else
        tmux attach-session -t "$SESSION_NAME"
    fi
}

# Main execution
main() {
    parse_options "$@"
    load_project_config
    validate_inputs
    create_session
    attach_session
}

# Run main function
main "$@"