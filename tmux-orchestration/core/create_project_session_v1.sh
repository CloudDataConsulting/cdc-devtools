#!/usr/bin/env bash
# CDC Project Session Creator
# Creates standardized tmux sessions with consistent logging and monitoring

# Source the logging framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging_framework.sh"

# Default configuration
readonly DEFAULT_LAYOUT="main-vertical"
readonly DEFAULT_PANES=3

# Usage function
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] SESSION_NAME PROJECT_PATH

Creates a standardized tmux session for CDC projects with logging enabled.

OPTIONS:
    -l LAYOUT     Tmux layout (default: main-vertical)
    -p PANES      Number of panes (default: 3)
    -t TEMPLATE   Use template from templates/ directory
    -h            Show this help message

EXAMPLES:
    $(basename "$0") myproject ~/repos/myproject
    $(basename "$0") -t ai-agent-project aibot ~/repos/aibot
    $(basename "$0") -l tiled -p 4 analytics ~/repos/analytics

EOF
    exit 1
}

# Parse command line options
parse_options() {
    local OPTIND
    LAYOUT=$DEFAULT_LAYOUT
    PANES=$DEFAULT_PANES
    TEMPLATE=""
    
    while getopts "l:p:t:h" opt; do
        case $opt in
            l) LAYOUT=$OPTARG ;;
            p) PANES=$OPTARG ;;
            t) TEMPLATE=$OPTARG ;;
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

# Create tmux session
create_session() {
    log_info "Creating tmux session: $SESSION_NAME"
    
    # Start logging session
    start_log_session "$SESSION_NAME"
    
    # Create new session with first window
    tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_PATH" -n "main"
    
    # Set up environment variables in session
    tmux send-keys -t "$SESSION_NAME:0" "export CDC_SESSION_NAME='$SESSION_NAME'" C-m
    tmux send-keys -t "$SESSION_NAME:0" "export CDC_PROJECT_PATH='$PROJECT_PATH'" C-m
    tmux send-keys -t "$SESSION_NAME:0" "export CDC_LOG_DIR='$CDC_LOG_DIR'" C-m
    
    # Source logging framework in main pane
    tmux send-keys -t "$SESSION_NAME:0" "source $SCRIPT_DIR/logging_framework.sh" C-m
    
    # Create additional panes
    for ((i=1; i<$PANES; i++)); do
        tmux split-window -t "$SESSION_NAME:0" -c "$PROJECT_PATH"
        tmux send-keys -t "$SESSION_NAME:0.$i" "source $SCRIPT_DIR/logging_framework.sh" C-m
    done
    
    # Apply layout
    tmux select-layout -t "$SESSION_NAME:0" "$LAYOUT"
    
    # Apply template if specified
    if [[ -n "$TEMPLATE_PATH" ]]; then
        log_info "Applying template: $TEMPLATE"
        source "$TEMPLATE_PATH"
        apply_template "$SESSION_NAME" "$PROJECT_PATH"
    fi
    
    # Create monitoring window
    create_monitoring_window
    
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
    tmux send-keys -t "$SESSION_NAME:monitor" "# Use this window to run monitoring commands" C-m
    tmux send-keys -t "$SESSION_NAME:monitor" "tail -f $CDC_LOG_DIR/cdc-$(date +%Y%m%d).log" C-m
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
    validate_inputs
    create_session
    attach_session
}

# Run main function
main "$@"