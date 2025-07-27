.
├── ai-agents
│   ├── __init__.py
│   ├── base-agents
│   │   ├── __init__.py
│   │   ├── git_aware_agent.py
│   │   ├── git_manager.py
│   │   ├── model_aware_agent.py
│   │   ├── model_router.py
│   │   └── usage_tracker.py
│   ├── config
│   │   ├── git_strategy.yaml
│   │   └── model_routing.yaml
│   ├── examples
│   │   ├── __init__.py
│   │   ├── auto_commit_agent.py
│   │   └── model_aware_orchestrator.py
│   ├── orchestrators
│   └── README.md
├── bin
│   ├── cdc-analyze-models -> ../monitoring/analyze_model_usage.py
│   ├── cdc-create-session -> ../tmux-orchestration/core/create_project_session.sh
│   ├── cdc-git-monitor -> ../monitoring/git_activity_monitor.py
│   ├── cdc-import-project -> ../tmux-orchestration/core/import_project.sh
│   ├── cdc-monitor -> ../monitoring/unified_dashboard.sh
│   ├── cdc-monitor-project -> ../monitoring/monitor_project.sh
│   ├── cdc-onboard -> ../team-setup/onboard_developer.sh
│   └── cdc-summary -> ../monitoring/generate_summary.py
├── cdc-devtool-tree.md
├── developer-config
│   ├── ANALYSIS_REPORT.md
│   ├── git
│   │   ├── gitconfig.template
│   │   └── gitignore.global
│   ├── HOME_DIRECTORY_ANALYSIS.md
│   ├── install.sh
│   ├── INTEGRATION_PLAN.md
│   ├── MIGRATION_GUIDE.md
│   ├── patterns
│   │   └── symlink-configs.sh
│   ├── personal
│   │   └── README.md
│   ├── README.md
│   ├── security
│   │   └── 1password-git-signing.md
│   ├── shell
│   │   ├── aliases.sh
│   │   └── functions.sh
│   ├── templates
│   └── tmux
│       └── tmux.conf.cdc
├── docs
│   └── SECRETS_MANAGEMENT.md
├── git-hooks
│   └── prepare-commit-msg
├── monitoring
│   ├── analyze_model_usage.py
│   ├── generate_summary.py
│   ├── git_activity_monitor.py
│   ├── monitor_project.sh
│   ├── slack_notifications.py
│   └── unified_dashboard.sh
├── NEXT_STEPS.md
├── prompts
│   ├── 01-project_init.md
│   ├── 02-import-and-organize.md
│   ├── 03-model-routing-feature.md
│   ├── 04-add-automated-workflow.md
│   ├── 05-merge-bpruss_config.md
│   ├── 06-review-env-creds-strategy.md
│   ├── 07-review-home-files.md
│   ├── 99-windows-support.md
│   ├── claude-app-summary-01.md
│   └── convert-prj-env-yaml.md
├── README.md
├── secrets-management
│   ├── __init__.py
│   ├── base_secrets_manager.py
│   ├── examples
│   │   ├── database_connections.py
│   │   └── multi_aws_example.py
│   ├── terraform_helper.py
│   └── tmux_aware_secrets.py
├── SETUP_GUIDE.md
├── team-setup
│   ├── config
│   │   └── cdc_defaults.conf
│   └── onboard_developer.sh
├── templates
│   └── config.yaml.example
└── tmux-orchestration
    ├── core
    │   ├── config_parser.sh
    │   ├── create_project_session_v1.sh
    │   ├── create_project_session.sh
    │   ├── import_project.sh
    │   ├── logging_framework.sh
    │   ├── monitoring_base.sh
    │   └── tmux_secrets_integration.sh
    ├── README.md
    └── templates
        ├── ai-agent-project
        │   ├── setup_logging.sh
        │   └── setup.sh
        ├── basic-project
        │   └── setup.sh
        └── multi-account-project
            └── configs
                ├── aws-config.yaml
                └── orchestrator-config.yaml

31 directories, 79 files
