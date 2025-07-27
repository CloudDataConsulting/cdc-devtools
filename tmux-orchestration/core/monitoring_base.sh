#!/usr/bin/env bash
# CDC Monitoring Base
# Base functions for monitoring CDC projects and sessions

# Source the logging framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging_framework.sh"

# Monitoring configuration
readonly MONITOR_INTERVAL=${CDC_MONITOR_INTERVAL:-5}
readonly MONITOR_HISTORY_SIZE=${CDC_MONITOR_HISTORY_SIZE:-100}

# Get active tmux sessions
get_active_sessions() {
    tmux list-sessions -F "#{session_name}" 2>/dev/null || echo ""
}

# Get session info
get_session_info() {
    local session=$1
    tmux list-windows -t "$session" -F "#{window_index}:#{window_name}:#{window_active}" 2>/dev/null
}

# Get system resource usage
get_system_resources() {
    local cpu_usage=""
    local mem_usage=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
        mem_usage=$(top -l 1 | grep "PhysMem" | awk '{print $2}' | sed 's/M//')
    else
        # Linux
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        mem_usage=$(free -m | awk 'NR==2{printf "%.1f", $3/$2*100}')
    fi
    
    echo "CPU: ${cpu_usage}% MEM: ${mem_usage}%"
}

# Monitor specific session
monitor_session() {
    local session=$1
    local windows=$(get_session_info "$session")
    local resources=$(get_system_resources)
    
    echo "Session: $session"
    echo "Resources: $resources"
    echo "Windows:"
    echo "$windows" | while IFS=: read -r idx name active; do
        local marker=""
        [[ "$active" == "1" ]] && marker="*"
        echo "  [$idx] $name $marker"
    done
    echo ""
}

# Monitor all CDC sessions
monitor_all_sessions() {
    local sessions=$(get_active_sessions)
    
    if [[ -z "$sessions" ]]; then
        log_warn "No active tmux sessions found"
        return
    fi
    
    echo "=== CDC Session Monitor ==="
    echo "Time: $(get_timestamp)"
    echo ""
    
    for session in $sessions; do
        monitor_session "$session"
    done
}

# Continuous monitoring loop
start_continuous_monitoring() {
    log_info "Starting continuous monitoring (interval: ${MONITOR_INTERVAL}s)"
    
    while true; do
        clear
        monitor_all_sessions
        sleep $MONITOR_INTERVAL
    done
}

# Check session health
check_session_health() {
    local session=$1
    local healthy=true
    local issues=()
    
    # Check if session exists
    if ! tmux has-session -t "$session" 2>/dev/null; then
        healthy=false
        issues+=("Session does not exist")
    else
        # Check for zombie panes
        local pane_count=$(tmux list-panes -t "$session" | wc -l)
        if [[ $pane_count -eq 0 ]]; then
            healthy=false
            issues+=("No panes in session")
        fi
        
        # Check for responsive panes
        tmux list-panes -t "$session" -F "#{pane_id}:#{pane_dead}" | while IFS=: read -r pane_id dead; do
            if [[ "$dead" == "1" ]]; then
                healthy=false
                issues+=("Dead pane: $pane_id")
            fi
        done
    fi
    
    if $healthy; then
        echo "HEALTHY"
    else
        echo "UNHEALTHY: ${issues[*]}"
    fi
}

# Export functions
export -f get_active_sessions get_session_info get_system_resources monitor_session monitor_all_sessions start_continuous_monitoring check_session_health