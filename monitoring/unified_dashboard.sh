#!/usr/bin/env bash
# CDC Unified Dashboard
# Monitor all CDC projects and sessions from a single interface

# Source monitoring base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../tmux-orchestration/core/monitoring_base.sh"

# Dashboard configuration
readonly DASHBOARD_REFRESH_RATE=${CDC_DASHBOARD_REFRESH:-3}
readonly DASHBOARD_SESSION_NAME="cdc-dashboard"

# Usage function
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

CDC Unified Dashboard - Monitor all CDC projects and sessions

OPTIONS:
    -r RATE     Refresh rate in seconds (default: 3)
    -d          Detached mode (create dashboard session without attaching)
    -k          Kill existing dashboard session
    -h          Show this help message

EXAMPLES:
    $(basename "$0")              # Start dashboard
    $(basename "$0") -r 5         # Start with 5 second refresh
    $(basename "$0") -k           # Kill dashboard session

EOF
    exit 1
}

# Parse options
parse_options() {
    local OPTIND
    REFRESH_RATE=$DASHBOARD_REFRESH_RATE
    DETACHED=false
    KILL_SESSION=false
    
    while getopts "r:dkh" opt; do
        case $opt in
            r) REFRESH_RATE=$OPTARG ;;
            d) DETACHED=true ;;
            k) KILL_SESSION=true ;;
            h) usage ;;
            *) usage ;;
        esac
    done
}

# Kill dashboard session
kill_dashboard() {
    if tmux has-session -t "$DASHBOARD_SESSION_NAME" 2>/dev/null; then
        log_info "Killing dashboard session"
        tmux kill-session -t "$DASHBOARD_SESSION_NAME"
    else
        log_warn "Dashboard session not found"
    fi
}

# Create dashboard layout
create_dashboard_layout() {
    # Main monitoring pane (70% width)
    tmux send-keys -t "$DASHBOARD_SESSION_NAME:0.0" "$SCRIPT_DIR/../tmux-orchestration/core/monitoring_base.sh && start_continuous_monitoring" C-m
    
    # Split right for logs (30% width)
    tmux split-window -h -t "$DASHBOARD_SESSION_NAME:0" -p 30
    tmux send-keys -t "$DASHBOARD_SESSION_NAME:0.1" "tail -f $CDC_LOG_DIR/cdc-*.log | grep -E 'ERROR|WARN'" C-m
    
    # Split bottom for session health
    tmux split-window -v -t "$DASHBOARD_SESSION_NAME:0.1" -p 50
    
    # Health check loop
    tmux send-keys -t "$DASHBOARD_SESSION_NAME:0.2" "while true; do clear; echo '=== Session Health ==='; for s in \$(tmux ls -F '#{session_name}' 2>/dev/null); do echo -n \"\$s: \"; $SCRIPT_DIR/../tmux-orchestration/core/monitoring_base.sh && check_session_health \"\$s\"; done; sleep 5; done" C-m
}

# Create dashboard session
create_dashboard() {
    log_info "Creating unified dashboard"
    
    # Kill existing session if requested
    if $KILL_SESSION; then
        kill_dashboard
        exit 0
    fi
    
    # Check if dashboard already exists
    if tmux has-session -t "$DASHBOARD_SESSION_NAME" 2>/dev/null; then
        log_warn "Dashboard session already exists. Use -k to kill it first."
        if ! $DETACHED; then
            attach_dashboard
        fi
        exit 0
    fi
    
    # Create new dashboard session
    tmux new-session -d -s "$DASHBOARD_SESSION_NAME" -n "monitor"
    
    # Set up environment
    tmux send-keys -t "$DASHBOARD_SESSION_NAME:0" "export CDC_MONITOR_INTERVAL=$REFRESH_RATE" C-m
    tmux send-keys -t "$DASHBOARD_SESSION_NAME:0" "export PATH=$PATH:$SCRIPT_DIR/../tmux-orchestration/core" C-m
    
    # Create dashboard layout
    create_dashboard_layout
    
    # Create command window
    tmux new-window -t "$DASHBOARD_SESSION_NAME" -n "control"
    tmux send-keys -t "$DASHBOARD_SESSION_NAME:control" "# Dashboard Control Window" C-m
    tmux send-keys -t "$DASHBOARD_SESSION_NAME:control" "# Use this window to manage sessions" C-m
    
    # Select monitor window
    tmux select-window -t "$DASHBOARD_SESSION_NAME:monitor"
    
    log_info "Dashboard created successfully"
}

# Attach to dashboard
attach_dashboard() {
    log_info "Attaching to dashboard"
    
    if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$DASHBOARD_SESSION_NAME"
    else
        tmux attach-session -t "$DASHBOARD_SESSION_NAME"
    fi
}

# Main execution
main() {
    parse_options "$@"
    
    if $KILL_SESSION; then
        kill_dashboard
    else
        create_dashboard
        if ! $DETACHED; then
            attach_dashboard
        fi
    fi
}

# Run main
main "$@"