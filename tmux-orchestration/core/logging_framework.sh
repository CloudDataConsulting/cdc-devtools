#!/usr/bin/env bash
# CDC Logging Framework
# Provides consistent logging functionality across all CDC tools

# Set default log directory if not provided
: ${CDC_LOG_DIR:="$HOME/.cdc/logs"}

# Ensure log directory exists
mkdir -p "$CDC_LOG_DIR"

# Color codes for terminal output
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_CYAN='\033[0;36m'

# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3

# Default log level
: ${CDC_LOG_LEVEL:=$LOG_LEVEL_INFO}

# Get timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Log to file and optionally to stdout
log_message() {
    local level=$1
    local message=$2
    local color=$3
    local timestamp=$(get_timestamp)
    local log_file="${CDC_LOG_DIR}/cdc-$(date +%Y%m%d).log"
    
    # Log to file
    echo "[$timestamp] [$level] $message" >> "$log_file"
    
    # Log to stdout if not silent
    if [[ -z $CDC_SILENT ]]; then
        echo -e "${color}[$timestamp] [$level]${COLOR_RESET} $message"
    fi
}

# Debug logging
log_debug() {
    [[ $CDC_LOG_LEVEL -le $LOG_LEVEL_DEBUG ]] && log_message "DEBUG" "$1" "$COLOR_CYAN"
}

# Info logging
log_info() {
    [[ $CDC_LOG_LEVEL -le $LOG_LEVEL_INFO ]] && log_message "INFO" "$1" "$COLOR_GREEN"
}

# Warning logging
log_warn() {
    [[ $CDC_LOG_LEVEL -le $LOG_LEVEL_WARN ]] && log_message "WARN" "$1" "$COLOR_YELLOW"
}

# Error logging
log_error() {
    [[ $CDC_LOG_LEVEL -le $LOG_LEVEL_ERROR ]] && log_message "ERROR" "$1" "$COLOR_RED"
}

# Start logging session
start_log_session() {
    local session_name=$1
    log_info "Starting logging session: $session_name"
    export CDC_SESSION_NAME=$session_name
    export CDC_SESSION_START=$(date +%s)
}

# End logging session
end_log_session() {
    local duration=$(($(date +%s) - CDC_SESSION_START))
    log_info "Ending logging session: $CDC_SESSION_NAME (duration: ${duration}s)"
}

# Rotate logs older than 30 days
rotate_logs() {
    log_info "Rotating logs older than 30 days"
    find "$CDC_LOG_DIR" -name "cdc-*.log" -mtime +30 -delete
}

# Export functions for use in other scripts
export -f get_timestamp log_message log_debug log_info log_warn log_error start_log_session end_log_session rotate_logs