#!/usr/bin/env bash
# CDC Developer Configuration Installer
# Installs team-wide development configurations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation options
INSTALL_SHELL=false
INSTALL_GIT=false
INSTALL_TMUX=false
INSTALL_ALL=false
MINIMAL_MODE=false
FORCE_MODE=false

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.cdc_config_backup_$(date +%Y%m%d_%H%M%S)"
CDC_CONFIG_DIR="$HOME/.cdc"

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo -e "\n${BLUE}===========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

confirm() {
    local prompt="$1"
    local response
    
    if [[ "$FORCE_MODE" == "true" ]]; then
        return 0
    fi
    
    read -p "$prompt (y/N) " -n 1 -r response
    echo
    [[ "$response" =~ ^[Yy]$ ]]
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/$(basename "$file")"
        print_info "Backed up $file to $BACKUP_DIR"
    fi
}

# ============================================================================
# Installation Functions
# ============================================================================

detect_shell() {
    if [[ -n "${SHELL:-}" ]]; then
        case "$SHELL" in
            */zsh) echo "zsh" ;;
            */bash) echo "bash" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

install_shell_configs() {
    print_header "Installing Shell Configurations"
    
    local shell_type=$(detect_shell)
    print_info "Detected shell: $shell_type"
    
    # Create CDC config directory
    mkdir -p "$CDC_CONFIG_DIR"
    
    # Install aliases
    if [[ -f "$SCRIPT_DIR/shell/aliases.sh" ]]; then
        cp "$SCRIPT_DIR/shell/aliases.sh" "$CDC_CONFIG_DIR/aliases.sh"
        print_success "Installed CDC aliases"
    fi
    
    # Install functions
    if [[ -f "$SCRIPT_DIR/shell/functions.sh" ]]; then
        cp "$SCRIPT_DIR/shell/functions.sh" "$CDC_CONFIG_DIR/functions.sh"
        print_success "Installed CDC functions"
    fi
    
    # Setup shell RC file integration
    local rc_file=""
    case "$shell_type" in
        zsh) rc_file="$HOME/.zshrc" ;;
        bash) rc_file="$HOME/.bashrc" ;;
        *)
            print_warning "Unknown shell type. Please manually add source commands to your shell RC file."
            return
            ;;
    esac
    
    if [[ -f "$rc_file" ]]; then
        backup_file "$rc_file"
        
        # Check if CDC config is already sourced
        if ! grep -q "CDC Developer Configuration" "$rc_file"; then
            cat >> "$rc_file" << 'EOF'

# ============================================================================
# CDC Developer Configuration
# ============================================================================
export CDC_WORKSPACE="${CDC_WORKSPACE:-$HOME/repos/cdc}"
export CDC_CONFIG_DIR="$HOME/.cdc"

# Source CDC configurations if they exist
[[ -f "$CDC_CONFIG_DIR/aliases.sh" ]] && source "$CDC_CONFIG_DIR/aliases.sh"
[[ -f "$CDC_CONFIG_DIR/functions.sh" ]] && source "$CDC_CONFIG_DIR/functions.sh"

# Source personal configurations if they exist
[[ -f "$HOME/.cdc_personal" ]] && source "$HOME/.cdc_personal"
[[ -f "$HOME/.cdc_clients" ]] && source "$HOME/.cdc_clients"
[[ -f "$HOME/.cdc_env" ]] && source "$HOME/.cdc_env"
EOF
            print_success "Added CDC configuration to $rc_file"
        else
            print_info "CDC configuration already exists in $rc_file"
        fi
    fi
    
    # Create example personal config files
    if [[ ! -f "$HOME/.cdc_personal" ]]; then
        cat > "$HOME/.cdc_personal" << 'EOF'
#!/usr/bin/env bash
# Personal CDC Configuration
# Add your personal aliases and functions here

# Example personal alias
# alias myproject="cd ~/my-personal-project"

# Example personal function
# my_function() {
#     echo "This is my personal function"
# }
EOF
        print_success "Created example personal config at ~/.cdc_personal"
    fi
    
    if [[ ! -f "$HOME/.cdc_clients" ]]; then
        cat > "$HOME/.cdc_clients" << 'EOF'
#!/usr/bin/env bash
# Client-Specific CDC Configuration
# Add client-specific aliases and functions here

# Example client shortcuts
# alias client1="cd $CDC_WORKSPACE/client1 && source env.sh"
# alias client2="cd $CDC_WORKSPACE/client2"

# Example client function
# client_deploy() {
#     echo "Deploying to client environment..."
# }
EOF
        print_success "Created example client config at ~/.cdc_clients"
    fi
}

install_git_configs() {
    print_header "Installing Git Configuration"
    
    local gitconfig="$HOME/.gitconfig"
    local gitignore_global="$HOME/.gitignore_global"
    
    # Install gitignore_global
    if [[ -f "$SCRIPT_DIR/git/gitignore.global" ]]; then
        if [[ -f "$gitignore_global" ]]; then
            backup_file "$gitignore_global"
        fi
        cp "$SCRIPT_DIR/git/gitignore.global" "$gitignore_global"
        print_success "Installed global gitignore"
    fi
    
    # Handle gitconfig
    if [[ -f "$gitconfig" ]]; then
        if [[ "$MINIMAL_MODE" == "true" ]]; then
            print_info "Minimal mode: Skipping gitconfig (file exists)"
            return
        fi
        
        backup_file "$gitconfig"
        
        if confirm "Git config exists. Would you like to merge CDC settings?"; then
            # Extract user info from existing config
            local user_name=$(git config --global user.name || echo "")
            local user_email=$(git config --global user.email || echo "")
            
            # Create new config from template
            cp "$SCRIPT_DIR/git/gitconfig.template" "$gitconfig.cdc_new"
            
            # Replace placeholders
            if [[ -n "$user_name" ]]; then
                sed -i.bak "s/YOUR_NAME/$user_name/g" "$gitconfig.cdc_new"
            fi
            if [[ -n "$user_email" ]]; then
                sed -i.bak "s/YOUR_EMAIL@clouddataconsulting.com/$user_email/g" "$gitconfig.cdc_new"
            fi
            rm -f "$gitconfig.cdc_new.bak"
            
            print_info "New git config created at $gitconfig.cdc_new"
            print_info "Please review and manually merge if desired"
        fi
    else
        # No existing gitconfig, install template
        cp "$SCRIPT_DIR/git/gitconfig.template" "$gitconfig"
        
        print_warning "Git config installed. Please update:"
        print_warning "  - user.name"
        print_warning "  - user.email"
        print_warning "Run: git config --global user.name 'Your Name'"
        print_warning "Run: git config --global user.email 'your.email@clouddataconsulting.com'"
    fi
}

install_tmux_configs() {
    print_header "Installing Tmux Configuration"
    
    local tmux_conf="$HOME/.tmux.conf"
    local tmux_cdc="$SCRIPT_DIR/tmux/tmux.conf.cdc"
    
    if [[ ! -f "$tmux_cdc" ]]; then
        print_warning "Tmux configuration not found in $tmux_cdc"
        return
    fi
    
    if [[ -f "$tmux_conf" ]]; then
        if [[ "$MINIMAL_MODE" == "true" ]]; then
            print_info "Minimal mode: Skipping tmux config (file exists)"
            return
        fi
        
        backup_file "$tmux_conf"
        
        if confirm "Tmux config exists. Would you like to install CDC version?"; then
            cp "$tmux_cdc" "$tmux_conf"
            print_success "Installed CDC tmux configuration"
        fi
    else
        cp "$tmux_cdc" "$tmux_conf"
        print_success "Installed CDC tmux configuration"
    fi
}

check_for_env_files() {
    print_header "Checking for Legacy env.sh Files"
    
    local env_files=$(find "$HOME" -name "env.sh" -type f 2>/dev/null | grep -E "(repos|projects|work)" | head -10)
    
    if [[ -n "$env_files" ]]; then
        print_warning "Found legacy env.sh files that should be migrated to config.yaml:"
        echo "$env_files" | while read -r file; do
            echo "  - $file"
        done
        echo
        print_info "See $CDC_WORKSPACE/cdc-devtools/docs/SECRETS_MANAGEMENT.md for migration guide"
        print_info "The new approach eliminates environment variable conflicts and supports multi-account workflows"
    else
        print_success "No legacy env.sh files found in common locations"
    fi
}

setup_cdc_workspace() {
    print_header "Setting Up CDC Workspace"
    
    local default_workspace="$HOME/repos/cdc"
    local workspace_path=""
    
    if [[ -d "$default_workspace" ]]; then
        print_info "Found existing CDC workspace at $default_workspace"
        workspace_path="$default_workspace"
    else
        print_info "CDC workspace not found at default location"
        read -p "Enter CDC workspace path (or press Enter for $default_workspace): " workspace_path
        workspace_path="${workspace_path:-$default_workspace}"
        
        if [[ ! -d "$workspace_path" ]]; then
            if confirm "Create CDC workspace at $workspace_path?"; then
                mkdir -p "$workspace_path"
                print_success "Created CDC workspace at $workspace_path"
            fi
        fi
    fi
    
    # Update shell config with workspace path if not default
    if [[ "$workspace_path" != "$default_workspace" ]]; then
        echo "export CDC_WORKSPACE=\"$workspace_path\"" >> "$HOME/.cdc_env"
        print_success "Set CDC_WORKSPACE to $workspace_path"
    fi
}

# ============================================================================
# Main Installation Flow
# ============================================================================

show_usage() {
    cat << EOF
CDC Developer Configuration Installer

Usage: ./install.sh [OPTIONS]

Options:
    --all           Install all configurations
    --shell         Install shell configurations only
    --git           Install git configurations only
    --tmux          Install tmux configurations only
    --minimal       Minimal installation (skip existing files)
    --force         Force installation without prompts
    -h, --help      Show this help message

Examples:
    ./install.sh --all          # Install everything
    ./install.sh --shell --git  # Install shell and git configs
    ./install.sh --minimal      # Minimal setup
EOF
}

parse_arguments() {
    if [[ $# -eq 0 ]]; then
        INSTALL_ALL=true
        return
    fi
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                INSTALL_ALL=true
                shift
                ;;
            --shell)
                INSTALL_SHELL=true
                shift
                ;;
            --git)
                INSTALL_GIT=true
                shift
                ;;
            --tmux)
                INSTALL_TMUX=true
                shift
                ;;
            --minimal)
                MINIMAL_MODE=true
                shift
                ;;
            --force)
                FORCE_MODE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

main() {
    print_header "CDC Developer Configuration Installer"
    
    parse_arguments "$@"
    
    # If --all or no specific options, install everything
    if [[ "$INSTALL_ALL" == "true" ]] || \
       [[ "$INSTALL_SHELL" == "false" && "$INSTALL_GIT" == "false" && "$INSTALL_TMUX" == "false" ]]; then
        INSTALL_SHELL=true
        INSTALL_GIT=true
        INSTALL_TMUX=true
    fi
    
    print_info "Installation plan:"
    [[ "$INSTALL_SHELL" == "true" ]] && print_info "  - Shell configurations"
    [[ "$INSTALL_GIT" == "true" ]] && print_info "  - Git configurations"
    [[ "$INSTALL_TMUX" == "true" ]] && print_info "  - Tmux configurations"
    [[ "$MINIMAL_MODE" == "true" ]] && print_info "  - Minimal mode (skip existing)"
    [[ "$FORCE_MODE" == "true" ]] && print_info "  - Force mode (no prompts)"
    
    echo
    if ! confirm "Continue with installation?"; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    # Setup workspace first
    setup_cdc_workspace
    
    # Run installations
    [[ "$INSTALL_SHELL" == "true" ]] && install_shell_configs
    [[ "$INSTALL_GIT" == "true" ]] && install_git_configs
    [[ "$INSTALL_TMUX" == "true" ]] && install_tmux_configs
    
    # Check for old env.sh pattern
    check_for_env_files
    
    print_header "Installation Complete!"
    
    print_success "CDC developer configurations installed successfully"
    print_info "Backup created at: $BACKUP_DIR"
    
    echo
    print_info "Next steps:"
    print_info "1. Reload your shell: source ~/.$(basename $SHELL)rc"
    print_info "2. Update git config with your name and email"
    print_info "3. Customize ~/.cdc_personal with your personal configs"
    print_info "4. Add client configs to ~/.cdc_clients as needed"
    
    if [[ -f "$HOME/.gitconfig.cdc_new" ]]; then
        echo
        print_warning "Review new git config at ~/.gitconfig.cdc_new"
    fi
}

# Run main installation
main "$@"