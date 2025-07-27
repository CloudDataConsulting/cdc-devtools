# Import and Organize Existing Tools into CDC DevTools

Now let's import and generalize the existing working tools from my other projects.

## 1. Import Working Tmux Orchestration from cdc-ai

Copy these files from `~/repos/cdc/cdc-ai/scripts/`:
- `setup_ai_logging.sh`
- `start_logged_session.sh`
- `monitor_agents.sh`
- `generate_summary.py`

### Generalize them:
1. Replace all instances of `$HOME/repos/cdc/cdc-ai` with a configurable `$PROJECT_ROOT`
2. Replace hardcoded agent names with a configurable list that can be passed in or read from a config file
3. Make session names parameterized: instead of `cdc-ai-$DATE`, use `$PROJECT_NAME-$DATE`
4. Add parameters so they can be called like: `cdc-create-session "project-name" "path/to/project"`

### Place them as follows:
- `setup_ai_logging.sh` → `tmux-orchestration/templates/ai-agent-project/setup_logging.sh`
- `start_logged_session.sh` → `tmux-orchestration/core/create_project_session.sh` (generalized version)
- `monitor_agents.sh` → `monitoring/monitor_project.sh`
- `generate_summary.py` → `monitoring/generate_summary.py`

## 2. Import Personal Claude Agents

Copy everything from `~/claude-agents/` to `ai-agents/claude-imported/`

Then organize them into categories:
- Move any base/reusable agents to `ai-agents/base-agents/`
- Move any templates to `ai-agents/templates/`
- Keep project-specific ones in `ai-agents/claude-imported/` with a README explaining they're examples

## 3. Create Configuration System

Create `tmux-orchestration/core/config_parser.sh` that can read a project config file like:

```bash
# .cdc-project.conf
PROJECT_NAME="my-project"
PROJECT_TYPE="ai-agent-project"
AGENTS=(
    "orchestrator:Main Orchestrator"
    "data:Data Processing Agent"
    "api:API Integration Agent"
)
MONITORING_ENABLED=true
LOG_LEVEL="INFO"
```

## 4. Create the Master Script

Update `tmux-orchestration/core/create_project_session.sh` to:
1. Look for `.cdc-project.conf` in the target directory
2. If not found, prompt for project type (basic, ai-agent, data-pipeline, etc.)
3. Set up the appropriate tmux windows based on config
4. Enable logging for all windows
5. Start monitoring if enabled

## 5. Create Project Templates

In `tmux-orchestration/templates/`, create:

### ai-agent-project/
- `setup.sh` - Creates agent directories, logging structure
- `.cdc-project.conf` - Default config for AI projects
- `README_TEMPLATE.md` - Standard project documentation

### basic-project/
- Simpler version with just main/test/docs windows

## 6. Update bin/ Symlinks

Ensure these work:
- `cdc-create-session` → Points to the new generalized create_project_session.sh
- `cdc-monitor` → Points to monitor_project.sh with current directory as default
- `cdc-import-project` → New script to import existing project and add CDC tooling

## 7. Test the System

Create a test that:
1. Creates a new AI agent project
2. Verifies tmux session is created with correct windows
3. Confirms logging is working
4. Checks that monitoring shows activity

## 8. Documentation

Update README.md with:
- "Importing existing projects" section
- "Creating new CDC-enabled projects" section
- "Customizing your agent setup" section

Make sure to preserve all the excellent logging and monitoring functionality from the cdc-ai project while making it reusable across all CDC projects!
