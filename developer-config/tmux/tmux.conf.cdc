# CDC Tmux Configuration
# Optimized for development workflows

# ============================================================================
# General Settings
# ============================================================================

# Enable 256 colors
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Enable mouse support
set -g mouse on

# Set scrollback buffer size
set -g history-limit 50000

# Reduce escape time for vim
set -sg escape-time 10

# Enable focus events
set -g focus-events on

# Start window numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# ============================================================================
# Key Bindings
# ============================================================================

# Set prefix to Ctrl-a (easier to reach than Ctrl-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Reload config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Split windows with | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# Navigate panes with vim-style keys
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes with vim-style keys
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Quick window switching
bind -r C-h select-window -t :-
bind -r C-l select-window -t :+

# Synchronize panes toggle
bind S setw synchronize-panes \; display-message "Synchronize panes: #{?pane_synchronized,ON,OFF}"

# ============================================================================
# Copy Mode
# ============================================================================

# Use vim keybindings in copy mode
setw -g mode-keys vi

# Setup 'v' to begin selection as in Vim
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# Update default binding of `Enter` to also use copy-pipe
unbind -T copy-mode-vi Enter

# ============================================================================
# Status Bar
# ============================================================================

# Status bar position
set -g status-position bottom

# Update status bar every second
set -g status-interval 1

# Status bar colors
set -g status-style 'bg=#1e1e2e fg=#cdd6f4'

# Left side of status bar
set -g status-left-length 50
set -g status-left '#[fg=#89b4fa,bold]#S #[fg=#cdd6f4]| #[fg=#a6e3a1]#(whoami) '

# Right side of status bar
set -g status-right-length 100
set -g status-right '#[fg=#f9e2af]%Y-%m-%d #[fg=#cdd6f4]| #[fg=#cba6f7]%H:%M:%S #[fg=#cdd6f4]| #[fg=#89dceb]#h'

# Window status
set -g window-status-current-style 'fg=#1e1e2e bg=#89b4fa bold'
set -g window-status-current-format ' #I:#W#F '
set -g window-status-style 'fg=#bac2de'
set -g window-status-format ' #I:#W#F '

# Pane borders
set -g pane-border-style 'fg=#45475a'
set -g pane-active-border-style 'fg=#89b4fa'

# Message style
set -g message-style 'fg=#1e1e2e bg=#f9e2af bold'

# ============================================================================
# Plugins (optional - requires TPM)
# ============================================================================

# To use plugins, install TPM:
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# List of plugins
# set -g @plugin 'tmux-plugins/tpm'
# set -g @plugin 'tmux-plugins/tmux-sensible'
# set -g @plugin 'tmux-plugins/tmux-resurrect'
# set -g @plugin 'tmux-plugins/tmux-continuum'

# Initialize TMUX plugin manager (keep this line at the very bottom)
# run '~/.tmux/plugins/tpm/tpm'

# ============================================================================
# CDC Specific Settings
# ============================================================================

# Window naming
set -g automatic-rename on
set -g automatic-rename-format '#{b:pane_current_path}'

# Activity monitoring
setw -g monitor-activity on
set -g visual-activity off

# Display times
set -g display-panes-time 800
set -g display-time 1000

# ============================================================================
# Development Layouts
# ============================================================================

# Create development layout
bind D split-window -h -p 30 \; \
    split-window -v -p 50 \; \
    select-pane -t 0 \; \
    send-keys 'echo "Main development pane"' C-m \; \
    select-pane -t 1 \; \
    send-keys 'echo "Testing/monitoring pane"' C-m \; \
    select-pane -t 2 \; \
    send-keys 'echo "Logs/debugging pane"' C-m \; \
    select-pane -t 0

# Create AI orchestration layout
bind A new-window -n 'ai-orchestration' \; \
    split-window -h -p 25 \; \
    split-window -v -p 50 \; \
    select-pane -t 0 \; \
    split-window -v -p 30 \; \
    select-pane -t 0