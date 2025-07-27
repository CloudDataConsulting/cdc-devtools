#!/usr/bin/env bash
# CDC Developer Onboarding Script
# Sets up a new developer's environment with CDC tools and configurations

# Colors for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_BLUE='\033[0;34m'

# Configuration
readonly CDC_HOME="$HOME/.cdc"
readonly CDC_CONFIG_FILE="$CDC_HOME/config"
readonly DEVTOOLS_REPO="https://github.com/CloudDataConsulting/cdc-devtools.git"

# Print colored output
print_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"
}

print_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $1"
}

print_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1"
}

print_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1"
}

# Usage function
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Onboard a new CDC developer with standard tools and configurations.

OPTIONS:
    -n NAME       Developer name (required)
    -e EMAIL      Developer email (required)
    -t TEAM       Team name (optional)
    -s            Skip interactive prompts
    -h            Show this help message

EXAMPLE:
    $(basename "$0") -n "John Doe" -e "john.doe@clouddataconsulting.com"

EOF
    exit 1
}

# Parse options
parse_options() {
    local OPTIND
    DEV_NAME=""
    DEV_EMAIL=""
    DEV_TEAM=""
    SKIP_PROMPTS=false
    
    while getopts "n:e:t:sh" opt; do
        case $opt in
            n) DEV_NAME=$OPTARG ;;
            e) DEV_EMAIL=$OPTARG ;;
            t) DEV_TEAM=$OPTARG ;;
            s) SKIP_PROMPTS=true ;;
            h) usage ;;
            *) usage ;;
        esac
    done
    
    # Validate required options
    if [[ -z "$DEV_NAME" ]] || [[ -z "$DEV_EMAIL" ]]; then
        print_error "Name and email are required"
        usage
    fi
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check for required tools
    command -v git >/dev/null 2>&1 || missing_tools+=("git")
    command -v tmux >/dev/null 2>&1 || missing_tools+=("tmux")
    command -v gh >/dev/null 2>&1 || missing_tools+=("gh (GitHub CLI)")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install missing tools and try again"
        exit 1
    fi
    
    print_success "All prerequisites met"
}

# Create CDC directory structure
create_cdc_structure() {
    print_info "Creating CDC directory structure..."
    
    mkdir -p "$CDC_HOME"/{logs,config,templates,scripts}
    mkdir -p "$HOME/repos/cdc"
    
    print_success "Directory structure created"
}

# Clone devtools repository
clone_devtools() {
    print_info "Cloning CDC DevTools repository..."
    
    if [[ -d "$HOME/repos/cdc/cdc-devtools" ]]; then
        print_warn "DevTools repository already exists, updating..."
        cd "$HOME/repos/cdc/cdc-devtools" && git pull
    else
        git clone "$DEVTOOLS_REPO" "$HOME/repos/cdc/cdc-devtools"
    fi
    
    print_success "DevTools repository ready"
}

# Setup configuration
setup_config() {
    print_info "Setting up CDC configuration..."
    
    cat > "$CDC_CONFIG_FILE" << EOF
# CDC Developer Configuration
# Generated on $(date)

# Developer Information
CDC_DEVELOPER_NAME="$DEV_NAME"
CDC_DEVELOPER_EMAIL="$DEV_EMAIL"
CDC_DEVELOPER_TEAM="$DEV_TEAM"

# Paths
CDC_HOME="$CDC_HOME"
CDC_DEVTOOLS_PATH="$HOME/repos/cdc/cdc-devtools"
CDC_REPOS_PATH="$HOME/repos/cdc"

# Logging
CDC_LOG_DIR="$CDC_HOME/logs"
CDC_LOG_LEVEL=1  # 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR

# Monitoring
CDC_MONITOR_INTERVAL=5
CDC_DASHBOARD_REFRESH=3

# Export variables
export CDC_DEVELOPER_NAME CDC_DEVELOPER_EMAIL CDC_DEVELOPER_TEAM
export CDC_HOME CDC_DEVTOOLS_PATH CDC_REPOS_PATH
export CDC_LOG_DIR CDC_LOG_LEVEL
export CDC_MONITOR_INTERVAL CDC_DASHBOARD_REFRESH
EOF
    
    print_success "Configuration created at $CDC_CONFIG_FILE"
}

# Setup shell integration
setup_shell_integration() {
    print_info "Setting up shell integration..."
    
    local shell_rc=""
    local shell_name=""
    
    # Determine shell configuration file
    if [[ -n "$ZSH_VERSION" ]]; then
        shell_rc="$HOME/.zshrc"
        shell_name="zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        shell_rc="$HOME/.bashrc"
        shell_name="bash"
    else
        print_warn "Unknown shell, skipping integration"
        return
    fi
    
    # Check if already integrated
    if grep -q "CDC Developer Tools" "$shell_rc" 2>/dev/null; then
        print_warn "Shell integration already exists"
        return
    fi
    
    # Add integration
    cat >> "$shell_rc" << 'EOF'

# CDC Developer Tools
if [[ -f "$HOME/.cdc/config" ]]; then
    source "$HOME/.cdc/config"
fi

# Add CDC DevTools to PATH
if [[ -d "$HOME/repos/cdc/cdc-devtools/bin" ]]; then
    export PATH="$HOME/repos/cdc/cdc-devtools/bin:$PATH"
fi

# CDC aliases
alias cdc-session='cdc-create-session'
alias cdc-dash='cdc-monitor'
alias cdc-logs='tail -f $CDC_LOG_DIR/cdc-*.log'

EOF
    
    print_success "Shell integration added to $shell_rc"
}

# Setup git configuration
setup_git_config() {
    print_info "Setting up git configuration..."
    
    # Set user info if not already set
    if [[ -z "$(git config --global user.name)" ]]; then
        git config --global user.name "$DEV_NAME"
        print_success "Git user name set"
    fi
    
    if [[ -z "$(git config --global user.email)" ]]; then
        git config --global user.email "$DEV_EMAIL"
        print_success "Git user email set"
    fi
    
    # Set up useful aliases
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.st status
    git config --global alias.last 'log -1 HEAD'
    
    print_success "Git configuration complete"
}

# Create welcome script
create_welcome_script() {
    print_info "Creating welcome information..."
    
    cat > "$CDC_HOME/WELCOME.md" << EOF
# Welcome to CDC DevTools!

Hello $DEV_NAME,

Your CDC development environment has been set up successfully.

## Quick Start

1. **Create a new project session:**
   \`\`\`bash
   cdc-create-session myproject ~/repos/cdc/myproject
   \`\`\`

2. **Monitor all sessions:**
   \`\`\`bash
   cdc-monitor
   \`\`\`

3. **View logs:**
   \`\`\`bash
   cdc-logs
   \`\`\`

## Important Paths

- CDC Home: $CDC_HOME
- DevTools: $HOME/repos/cdc/cdc-devtools
- Repositories: $HOME/repos/cdc
- Logs: $CDC_HOME/logs

## Next Steps

1. Restart your shell or run: \`source ~/.${shell_name}rc\`
2. Explore the tools in $HOME/repos/cdc/cdc-devtools
3. Join the #dev-tools Slack channel for support

## Support

For issues or questions:
- Slack: #dev-tools
- Email: devtools@clouddataconsulting.com
- GitHub: https://github.com/CloudDataConsulting/cdc-devtools

Happy coding!
EOF
    
    print_success "Welcome information created"
}

# Final summary
show_summary() {
    echo ""
    echo "======================================"
    echo -e "${COLOR_GREEN}CDC Developer Onboarding Complete!${COLOR_RESET}"
    echo "======================================"
    echo ""
    echo "Developer: $DEV_NAME"
    echo "Email: $DEV_EMAIL"
    [[ -n "$DEV_TEAM" ]] && echo "Team: $DEV_TEAM"
    echo ""
    echo "Next steps:"
    echo "1. Restart your shell or run: source ~/.${shell_name:-bash}rc"
    echo "2. Read the welcome guide: cat $CDC_HOME/WELCOME.md"
    echo "3. Try creating a session: cdc-create-session test ~/repos/test"
    echo ""
}

# Main execution
main() {
    parse_options "$@"
    
    echo -e "${COLOR_BLUE}CDC Developer Onboarding${COLOR_RESET}"
    echo "=========================="
    echo ""
    
    check_prerequisites
    create_cdc_structure
    clone_devtools
    setup_config
    setup_shell_integration
    setup_git_config
    create_welcome_script
    
    show_summary
}

# Run main
main "$@"