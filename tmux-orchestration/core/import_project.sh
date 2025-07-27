#!/usr/bin/env bash
# CDC Import Project
# Imports an existing project and adds CDC tooling

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

# Usage function
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] PROJECT_PATH

Import an existing project and add CDC DevTools support.

OPTIONS:
    -n NAME       Project name (default: directory name)
    -t TYPE       Project type (default: basic-project)
                  Options: basic-project, ai-agent-project, data-pipeline,
                          api-service, snowflake-project
    -f            Force overwrite existing configuration
    -s            Skip git integration
    -h            Show this help message

EXAMPLES:
    $(basename "$0") ~/repos/myproject
    $(basename "$0") -n "ML Bot" -t ai-agent-project ~/repos/ml-bot
    $(basename "$0") -f ~/repos/existing-project

This will:
1. Create a .cdc-project.conf file
2. Set up logging directories
3. Add .gitignore entries
4. Create README sections for CDC tools
5. Optionally set up git hooks

EOF
    exit 1
}

# Parse options
parse_options() {
    local OPTIND
    PROJECT_NAME=""
    PROJECT_TYPE="basic-project"
    FORCE=false
    SKIP_GIT=false
    
    while getopts "n:t:fsh" opt; do
        case $opt in
            n) PROJECT_NAME=$OPTARG ;;
            t) PROJECT_TYPE=$OPTARG ;;
            f) FORCE=true ;;
            s) SKIP_GIT=true ;;
            h) usage ;;
            *) usage ;;
        esac
    done
    
    shift $((OPTIND-1))
    
    if [[ $# -ne 1 ]]; then
        log_error "Project path required"
        usage
    fi
    
    PROJECT_PATH=$1
    
    # Set default project name if not provided
    if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME=$(basename "$PROJECT_PATH")
    fi
}

# Validate inputs
validate_inputs() {
    # Check if project path exists
    if [[ ! -d "$PROJECT_PATH" ]]; then
        log_error "Project path '$PROJECT_PATH' does not exist"
        exit 1
    fi
    
    # Check if config already exists
    if [[ -f "$PROJECT_PATH/.cdc-project.conf" ]] && ! $FORCE; then
        log_error "Project already has CDC configuration. Use -f to overwrite."
        exit 1
    fi
    
    # Validate project type
    local valid_types=("basic-project" "ai-agent-project" "data-pipeline" "api-service" "snowflake-project")
    if [[ ! " ${valid_types[@]} " =~ " ${PROJECT_TYPE} " ]]; then
        log_error "Invalid project type: $PROJECT_TYPE"
        exit 1
    fi
}

# Import project
import_project() {
    log_info "Importing project: $PROJECT_NAME"
    
    # Create configuration file
    log_info "Creating CDC configuration..."
    create_project_config
    
    # Set up logging structure
    log_info "Setting up logging directories..."
    setup_logging_dirs
    
    # Update .gitignore
    if [[ -d "$PROJECT_PATH/.git" ]] && ! $SKIP_GIT; then
        log_info "Updating .gitignore..."
        update_gitignore
        
        # Set up git hooks
        log_info "Setting up git hooks..."
        setup_git_hooks "$PROJECT_PATH"
    fi
    
    # Add CDC section to README
    update_readme
    
    # Create initial log entry
    start_log_session "import-$PROJECT_NAME"
    log_info "Project imported successfully"
    end_log_session
    
    # Copy template files if they exist
    copy_template_files
    
    log_info "Import complete!"
}

# Create project configuration
create_project_config() {
    local template_conf="$SCRIPT_DIR/../templates/$PROJECT_TYPE/.cdc-project.conf"
    
    if [[ -f "$template_conf" ]]; then
        # Use template as base
        cp "$template_conf" "$PROJECT_PATH/.cdc-project.conf"
        
        # Update project name
        sed -i.bak "s/PROJECT_NAME=.*/PROJECT_NAME=\"$PROJECT_NAME\"/" "$PROJECT_PATH/.cdc-project.conf"
        rm -f "$PROJECT_PATH/.cdc-project.conf.bak"
    else
        # Create default config
        create_default_config "$PROJECT_PATH" "$PROJECT_NAME" "$PROJECT_TYPE"
    fi
    
    log_info "Created .cdc-project.conf"
}

# Set up logging directories
setup_logging_dirs() {
    mkdir -p "$PROJECT_PATH/logs"/{decisions,summaries,git-commits}
    mkdir -p "$PROJECT_PATH/logs/$(date +%Y-%m-%d)"
    
    # Create .gitkeep files to preserve directory structure
    touch "$PROJECT_PATH/logs/.gitkeep"
    touch "$PROJECT_PATH/logs/decisions/.gitkeep"
    touch "$PROJECT_PATH/logs/summaries/.gitkeep"
}

# Update .gitignore
update_gitignore() {
    local gitignore="$PROJECT_PATH/.gitignore"
    
    # Create if doesn't exist
    if [[ ! -f "$gitignore" ]]; then
        touch "$gitignore"
    fi
    
    # Check if CDC section already exists
    if grep -q "# CDC DevTools" "$gitignore"; then
        log_info ".gitignore already has CDC section"
        return
    fi
    
    # Add CDC entries
    cat >> "$gitignore" << 'EOF'

# CDC DevTools
logs/
*.log
.cdc/
.claude/settings.local.json
*.local
EOF
    
    log_info "Updated .gitignore"
}

# Update README
update_readme() {
    local readme=""
    
    # Find README file
    for file in README.md README.MD readme.md Readme.md; do
        if [[ -f "$PROJECT_PATH/$file" ]]; then
            readme="$PROJECT_PATH/$file"
            break
        fi
    done
    
    # Create README if it doesn't exist
    if [[ -z "$readme" ]]; then
        readme="$PROJECT_PATH/README.md"
        cat > "$readme" << EOF
# $PROJECT_NAME

Project description here.

EOF
    fi
    
    # Check if CDC section already exists
    if grep -q "CDC DevTools" "$readme"; then
        log_info "README already has CDC section"
        return
    fi
    
    # Add CDC section
    cat >> "$readme" << EOF

## CDC DevTools Integration

This project uses CDC DevTools for standardized development workflows.

### Quick Start

\`\`\`bash
# Create a tmux session for this project
cdc-create-session $PROJECT_NAME $PROJECT_PATH

# Monitor project activity
cdc-monitor-project

# Generate work summary
cdc-summary
\`\`\`

### Configuration

Project configuration is stored in \`.cdc-project.conf\`.

### Logs

- Session logs: \`logs/YYYY-MM-DD/\`
- Decision logs: \`logs/decisions/\`
- Git commit logs: \`logs/git-commits/\`

For more information, see the [CDC DevTools documentation](https://github.com/CloudDataConsulting/cdc-devtools).
EOF
    
    log_info "Updated README with CDC section"
}

# Copy template files
copy_template_files() {
    local template_dir="$SCRIPT_DIR/../templates/$PROJECT_TYPE"
    
    # Copy any additional template files (excluding .cdc-project.conf and setup.sh)
    if [[ -d "$template_dir" ]]; then
        for file in "$template_dir"/*; do
            local basename=$(basename "$file")
            if [[ "$basename" != ".cdc-project.conf" ]] && [[ "$basename" != "setup.sh" ]] && [[ -f "$file" ]]; then
                if [[ ! -f "$PROJECT_PATH/$basename" ]]; then
                    cp "$file" "$PROJECT_PATH/"
                    log_info "Copied template file: $basename"
                fi
            fi
        done
    fi
}

# Show next steps
show_next_steps() {
    echo ""
    echo "✅ Project imported successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Review and customize .cdc-project.conf"
    echo "2. Create a tmux session:"
    echo "   cdc-create-session $PROJECT_NAME $PROJECT_PATH"
    echo ""
    if [[ "$PROJECT_TYPE" == "ai-agent-project" ]]; then
        echo "3. Configure your AI agents in .cdc-project.conf"
        echo "4. Set up your Python environment:"
        echo "   cd $PROJECT_PATH && python -m venv venv"
        echo "   source venv/bin/activate && pip install -r requirements.txt"
    fi
    echo ""
}

# Main execution
main() {
    parse_options "$@"
    validate_inputs
    import_project
    show_next_steps
}

# Run main
main "$@"