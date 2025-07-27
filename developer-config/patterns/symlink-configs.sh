#!/usr/bin/env bash
# CDC Configuration Symlink Manager
# Safely create symlinks for configuration files

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CDC_CONFIG_DIR="${CDC_CONFIG_DIR:-$HOME/.cdc}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# Files to symlink (source:destination)
declare -A SYMLINKS=(
    ["$CDC_CONFIG_DIR/git/gitconfig"]="$HOME/.gitconfig"
    ["$CDC_CONFIG_DIR/git/gitignore_global"]="$HOME/.gitignore_global"
    ["$CDC_CONFIG_DIR/shell/aliases.sh"]="$HOME/.aliases"
    ["$CDC_CONFIG_DIR/shell/functions.sh"]="$HOME/.functions"
)

# Optional symlinks (ask user)
declare -A OPTIONAL_SYMLINKS=(
    ["$CDC_CONFIG_DIR/tmux/tmux.conf"]="$HOME/.tmux.conf"
    ["$CDC_CONFIG_DIR/aws/config"]="$HOME/.aws/config"
)

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

confirm() {
    local prompt="$1"
    local response
    read -p "$prompt (y/N) " -n 1 -r response
    echo
    [[ "$response" =~ ^[Yy]$ ]]
}

# Backup existing file
backup_file() {
    local file="$1"
    if [[ -e "$file" && ! -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        local basename=$(basename "$file")
        cp -a "$file" "$BACKUP_DIR/$basename"
        print_success "Backed up $file to $BACKUP_DIR/$basename"
        return 0
    fi
    return 1
}

# Create symlink safely
create_symlink() {
    local source="$1"
    local dest="$2"
    local force="${3:-false}"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        print_error "Source does not exist: $source"
        return 1
    fi
    
    # Handle existing destination
    if [[ -L "$dest" ]]; then
        # It's already a symlink
        local current_target=$(readlink "$dest")
        if [[ "$current_target" == "$source" ]]; then
            print_success "Already linked: $dest → $source"
            return 0
        else
            print_warning "Different symlink exists: $dest → $current_target"
            if [[ "$force" == "true" ]] || confirm "Replace with $source?"; then
                rm "$dest"
            else
                return 1
            fi
        fi
    elif [[ -e "$dest" ]]; then
        # Regular file exists
        print_warning "File exists: $dest"
        if backup_file "$dest"; then
            if [[ "$force" == "true" ]] || confirm "Replace with symlink to $source?"; then
                rm "$dest"
            else
                return 1
            fi
        fi
    fi
    
    # Create the symlink
    ln -s "$source" "$dest"
    print_success "Created: $dest → $source"
}

# Main execution
main() {
    print_header "CDC Configuration Symlink Manager"
    
    # Parse arguments
    local force=false
    local restore=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                force=true
                shift
                ;;
            -r|--restore)
                restore=true
                shift
                ;;
            -h|--help)
                cat << EOF
Usage: $0 [OPTIONS]

Options:
    -f, --force     Force symlink creation without prompting
    -r, --restore   Restore from most recent backup
    -h, --help      Show this help message

This script creates symlinks from CDC configuration files to their
standard locations, backing up any existing files.
EOF
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Check if CDC config directory exists
    if [[ ! -d "$CDC_CONFIG_DIR" ]]; then
        print_error "CDC config directory not found: $CDC_CONFIG_DIR"
        print_warning "Have you run the CDC DevTools installer?"
        exit 1
    fi
    
    # Restore mode
    if [[ "$restore" == "true" ]]; then
        print_header "Restore Mode"
        local latest_backup=$(ls -dt $HOME/.config-backup-* 2>/dev/null | head -1)
        if [[ -z "$latest_backup" ]]; then
            print_error "No backups found"
            exit 1
        fi
        
        print_warning "Restoring from: $latest_backup"
        if confirm "Continue?"; then
            # Remove symlinks and restore files
            for dest in "${SYMLINKS[@]}" "${OPTIONAL_SYMLINKS[@]}"; do
                if [[ -L "$dest" ]]; then
                    rm "$dest"
                    print_success "Removed symlink: $dest"
                fi
                
                local basename=$(basename "$dest")
                local backup_file="$latest_backup/$basename"
                if [[ -f "$backup_file" ]]; then
                    cp -a "$backup_file" "$dest"
                    print_success "Restored: $dest"
                fi
            done
        fi
        exit 0
    fi
    
    # Create required symlinks
    print_header "Creating Required Symlinks"
    for source in "${!SYMLINKS[@]}"; do
        create_symlink "$source" "${SYMLINKS[$source]}" "$force"
    done
    
    # Create optional symlinks
    print_header "Optional Symlinks"
    for source in "${!OPTIONAL_SYMLINKS[@]}"; do
        local dest="${OPTIONAL_SYMLINKS[$source]}"
        if [[ "$force" == "true" ]] || confirm "Create symlink for $(basename "$dest")?"; then
            create_symlink "$source" "$dest" "$force"
        fi
    done
    
    # Special handling for AWS directory
    if [[ -d "$CDC_CONFIG_DIR/aws" ]]; then
        print_header "AWS Configuration"
        if [[ ! -d "$HOME/.aws" ]]; then
            mkdir -p "$HOME/.aws"
            print_success "Created ~/.aws directory"
        fi
        
        # Only symlink config, never credentials
        if [[ -f "$CDC_CONFIG_DIR/aws/config" ]]; then
            if confirm "Symlink AWS config file?"; then
                create_symlink "$CDC_CONFIG_DIR/aws/config" "$HOME/.aws/config" "$force"
            fi
        fi
        
        print_warning "AWS credentials should NEVER be symlinked or stored in version control"
    fi
    
    # Summary
    print_header "Summary"
    if [[ -d "$BACKUP_DIR" ]]; then
        print_success "Backups saved to: $BACKUP_DIR"
    fi
    
    echo -e "\n${GREEN}Configuration symlinks created successfully!${NC}"
    echo -e "\nTo integrate with your shell, add to your .zshrc or .bashrc:"
    echo -e "${BLUE}# CDC Configurations"
    echo -e "[[ -f ~/.aliases ]] && source ~/.aliases"
    echo -e "[[ -f ~/.functions ]] && source ~/.functions${NC}"
    
    echo -e "\n${YELLOW}Note:${NC} Remember to:"
    echo "1. Reload your shell or source your RC file"
    echo "2. Never commit credentials to version control"
    echo "3. Use 'git config' to set your personal name/email"
}

# Run main
main "$@"