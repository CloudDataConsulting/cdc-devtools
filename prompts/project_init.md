# CDC DevTools Repository Setup

Please help me create a new CDC DevTools repository with the following structure and setup:

## Project: CDC Developer Toolkit

Create a comprehensive developer toolkit repository for Cloud Data Consulting that will be shared across our team.

### 1. Initialize Git and GitHub
- Initialize git repository
- Create GitHub repo named "cdc-devtools" in the CloudDataConsulting organization
- Set up main branch as default
- Create initial .gitignore for Python, Node, macOS, and logs

### 2. Create Directory Structure
```
cdc-devtools/
├── README.md
├── SETUP_GUIDE.md
├── tmux-orchestration/
│   ├── README.md
│   ├── install.sh
│   ├── core/
│   │   ├── create_project_session.sh
│   │   ├── logging_framework.sh
│   │   └── monitoring_base.sh
│   └── templates/
│       ├── basic-project/
│       └── ai-agent-project/
├── ai-agents/
│   ├── README.md
│   ├── base-agents/
│   ├── orchestrators/
│   └── examples/
├── monitoring/
│   ├── unified_dashboard.sh
│   └── slack_notifications.py
├── team-setup/
│   ├── onboard_developer.sh
│   └── config/
│       └── cdc_defaults.conf
└── bin/
```

### 3. Create Core Scripts

Start with these essential scripts:

1. **team-setup/onboard_developer.sh** - Script to onboard new team members
2. **tmux-orchestration/core/create_project_session.sh** - Creates standardized tmux sessions with logging
3. **tmux-orchestration/core/logging_framework.sh** - Reusable logging functionality
4. **monitoring/unified_dashboard.sh** - Monitor all CDC projects

### 4. Create README.md
Include:
- Overview of CDC DevTools
- Quick start guide
- Link to detailed SETUP_GUIDE.md
- Team contribution guidelines

### 5. Create Executable Symlinks
Create a bin/ directory with symlinks to commonly used scripts, prefixed with "cdc-":
- cdc-create-session -> tmux-orchestration/core/create_project_session.sh
- cdc-monitor -> monitoring/unified_dashboard.sh
- cdc-onboard -> team-setup/onboard_developer.sh

### 6. Set Permissions
Make all .sh scripts executable

### 7. Initial Commit
Commit with message: "Initial CDC DevTools structure - tmux orchestration, AI agents, and team setup"

### 8. Next Steps Output
After setup, please provide instructions for:
- How to clone and set up for a new team member
- How to create a new project session
- How to contribute new tools

Focus on making this immediately useful for the team, with the tmux orchestration being the first fully functional component.
