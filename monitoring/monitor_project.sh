#!/usr/bin/env bash
# Monitor project activity in real-time
# Generalized version that works with any CDC project

# Get project root from environment or current directory
PROJECT_ROOT=${CDC_PROJECT_PATH:-$(pwd)}
PROJECT_NAME=${CDC_PROJECT_NAME:-$(basename "$PROJECT_ROOT")}
DATE=$(date +%Y-%m-%d)

# Check if we're in a valid project
if [[ ! -d "$PROJECT_ROOT/logs" ]]; then
    echo "Error: No logs directory found in $PROJECT_ROOT"
    echo "Are you in a CDC project directory?"
    exit 1
fi

# Use watch to update every 2 seconds
watch -n 2 "
echo '🎯 CDC Project Activity Monitor - $PROJECT_NAME'
echo '=============================================='
echo
echo '📊 Active Sessions:'
tmux ls 2>/dev/null | grep -E '(cdc|$PROJECT_NAME)' || echo 'No active tmux sessions'
echo
echo '📝 Recent Log Activity:'
if [[ -d '$PROJECT_ROOT/logs/$DATE' ]]; then
    tail -n 10 $PROJECT_ROOT/logs/$DATE/*/session.log 2>/dev/null | grep -E '(✅|❌|🔄|⚠️|ERROR|WARN|INFO)' | tail -5 || echo 'No recent activity'
else
    echo 'No logs for today'
fi
echo
echo '📁 Log Files:'
if [[ -d '$PROJECT_ROOT/logs/$DATE' ]]; then
    find $PROJECT_ROOT/logs/$DATE -name '*.log' -type f 2>/dev/null | wc -l | xargs echo 'Total log files:'
    echo
    echo 'By component:'
    for dir in $PROJECT_ROOT/logs/$DATE/*/; do
        if [[ -d \$dir ]]; then
            component=\$(basename \$dir)
            count=\$(find \$dir -name '*.log' -type f 2>/dev/null | wc -l)
            printf '  %-20s %s\n' \$component \$count
        fi
    done
else
    echo 'No log directory for today'
fi
echo
echo '💾 Disk Usage:'
if [[ -d '$PROJECT_ROOT/logs' ]]; then
    du -sh $PROJECT_ROOT/logs 2>/dev/null | awk '{print \"Total logs: \" \$1}'
    if [[ -d '$PROJECT_ROOT/logs/$DATE' ]]; then
        du -sh $PROJECT_ROOT/logs/$DATE/* 2>/dev/null | sort -h | tail -5
    fi
fi
echo
echo '🕐 Last Update: \$(date +'%Y-%m-%d %H:%M:%S')'
"