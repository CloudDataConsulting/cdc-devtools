#!/usr/bin/env bash
# CDC Standard Shell Functions
# Shared functions for CDC development team

# ============================================================================
# Navigation Functions
# ============================================================================

# Go to CDC workspace
cdc() {
    cd "${CDC_WORKSPACE:-$HOME/repos/cdc}" || return 1
}

# Go to a specific CDC project
cdcp() {
    local project="$1"
    if [[ -z "$project" ]]; then
        echo "Usage: cdcp <project-name>"
        echo "Available projects:"
        ls -1 "${CDC_WORKSPACE:-$HOME/repos/cdc}"
        return 1
    fi
    cd "${CDC_WORKSPACE:-$HOME/repos/cdc}/$project" || return 1
}

# ============================================================================
# Git Functions
# ============================================================================

# Git branch cleanup - remove merged branches
git-cleanup() {
    echo "🧹 Cleaning up merged branches..."
    git fetch --prune
    git branch -vv | grep ": gone]" | awk '{print $1}' | xargs -r git branch -d
    echo "✅ Cleanup complete"
}

# Git sync main and current branch
git-sync() {
    local current_branch=$(git branch --show-current)
    echo "🔄 Syncing branches..."
    git checkout main && git pull
    git checkout "$current_branch" && git pull
    echo "✅ Sync complete"
}

# Create PR-ready branch
git-feature() {
    local feature_name="$1"
    if [[ -z "$feature_name" ]]; then
        echo "Usage: git-feature <feature-name>"
        return 1
    fi
    git checkout -b "feature/$feature_name"
}

# ============================================================================
# AWS Functions
# ============================================================================

# AWS SSO login helper
aws-login() {
    local profile="${1:-${AWS_PROFILE}}"
    if [[ -z "$profile" ]]; then
        echo "Usage: aws-login <profile-name>"
        echo "Available profiles:"
        aws configure list-profiles
        return 1
    fi
    aws sso login --profile "$profile"
    export AWS_PROFILE="$profile"
    echo "✅ Logged in to AWS profile: $profile"
}

# List AWS profiles
aws-profiles() {
    echo "Available AWS profiles:"
    aws configure list-profiles
    echo
    echo "Current profile: ${AWS_PROFILE:-none}"
}

# ============================================================================
# Environment Functions
# ============================================================================

# Load environment file with validation
load-env() {
    local env_file="${1:-env.sh}"
    if [[ ! -f "$env_file" ]]; then
        echo "❌ Environment file not found: $env_file"
        return 1
    fi
    echo "🔐 Loading environment from $env_file..."
    source "$env_file"
    echo "✅ Environment loaded"
}

# Show current environment
show-env() {
    echo "🌍 Current Environment Variables:"
    echo "CDC_WORKSPACE: ${CDC_WORKSPACE:-not set}"
    echo "AWS_PROFILE: ${AWS_PROFILE:-not set}"
    echo "AWS_REGION: ${AWS_REGION:-not set}"
    env | grep -E "^(CDC_|AWS_)" | sort
}

# ============================================================================
# Docker Functions
# ============================================================================

# Docker cleanup
docker-cleanup() {
    echo "🧹 Cleaning up Docker..."
    docker system prune -f
    docker volume prune -f
    echo "✅ Docker cleanup complete"
}

# Docker stop all containers
docker-stop-all() {
    echo "🛑 Stopping all containers..."
    docker stop $(docker ps -q) 2>/dev/null || echo "No running containers"
}

# ============================================================================
# Terraform Functions
# ============================================================================

# Terraform workspace helper
tf-workspace() {
    local action="$1"
    local workspace="$2"
    
    case "$action" in
        list|ls)
            terraform workspace list
            ;;
        select|sel)
            if [[ -z "$workspace" ]]; then
                echo "Usage: tf-workspace select <workspace-name>"
                return 1
            fi
            terraform workspace select "$workspace"
            ;;
        new)
            if [[ -z "$workspace" ]]; then
                echo "Usage: tf-workspace new <workspace-name>"
                return 1
            fi
            terraform workspace new "$workspace"
            ;;
        *)
            echo "Usage: tf-workspace {list|select|new} [workspace-name]"
            return 1
            ;;
    esac
}

# ============================================================================
# Utility Functions
# ============================================================================

# Extract various archive types
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1" || return 1
}

# Find files by name
ff() {
    find . -type f -iname "*$1*"
}

# Find directories by name
fd() {
    find . -type d -iname "*$1*"
}

# ============================================================================
# CDC DevTools Functions
# ============================================================================

# Update CDC DevTools
cdc-update() {
    echo "🔄 Updating CDC DevTools..."
    local current_dir=$(pwd)
    cd "${CDC_DEVTOOLS_PATH:-$HOME/repos/cdc/cdc-devtools}" || return 1
    git pull
    cd "$current_dir" || return 1
    echo "✅ CDC DevTools updated"
}

# ============================================================================
# Load Custom Functions
# ============================================================================

# Source client-specific functions if they exist
if [[ -f "$HOME/.cdc_clients_functions" ]]; then
    source "$HOME/.cdc_clients_functions"
fi

# Source personal functions if they exist
if [[ -f "$HOME/.cdc_personal_functions" ]]; then
    source "$HOME/.cdc_personal_functions"
fi