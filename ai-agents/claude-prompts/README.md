# CDC Claude Agents - Usage Pattern

This directory contains reusable specialist agents that are symlinked to `~/.claude/agents/` for easy access across all projects.

## Two-Tier System

### 1. Reusable Specialist Agents (This Repository)
- Live in `~/.claude/agents/` (symlinked from CDC DevTools)
- Named by category and specialization (e.g., `data-architect.md`)
- Used across all projects
- Under source control in CDC DevTools

### 2. Project Orchestrators (Individual Projects)
- Live in each project's directory (e.g., `project/.claude/orchestrator.md`)
- Know project-specific context
- Delegate to specialist agents
- Coordinate multi-agent workflows

## Quick Start

### Using Specialists Directly
```bash
# Browse available agents
ls ~/.claude/agents/

# View a specific agent
cat ~/.claude/agents/data-snowflake-architect-pro.md

# Copy into Claude.ai and use
```

### Project Workflow
```markdown
1. Project has its own orchestrator in `.claude/orchestrator.md`
2. Orchestrator understands the request
3. Orchestrator delegates to specialists:
   - "Use data-snowflake-architect-pro.md for schema design"
   - "Use code-reviewer.md for code review"
4. Orchestrator synthesizes results for project context
```

## Flat Structure

All agents follow the naming convention `[category]-[role].md`:

```
~/.claude/agents/
├── code-reviewer.md              # Code quality
├── code-systems-engineer.md      # System design
├── code-streamlit-builder.md     # Streamlit apps
├── data-snowflake-architect-pro.md
├── data-snowflake-data-architect.md
├── data-snowflake-rag-architect.md
├── devops-aws-snowflake-devops.md
├── devops-cloud-storage-optimizer.md
├── doc-technical-writer.md
├── security-compliance-engineer.md
├── test-data-integrity.md
└── _templates/                   # Templates for new agents
    ├── basic-agent.md
    └── project-orchestrator.md
```

## Categories

- **`code-`**: Code writing, reviewing, refactoring
- **`data-`**: Data engineering, SQL, analytics  
- **`devops-`**: Infrastructure, deployment, CI/CD
- **`doc-`**: Documentation, technical writing
- **`security-`**: Security analysis, compliance
- **`test-`**: Testing strategies, QA
- **`api-`**: API design and integration
- **`core-`**: Fundamental coordination agents

See `NAMING_CONVENTION.md` for detailed naming rules.

## Creating a Project Orchestrator

Every project should have its own orchestrator:

```bash
# In your project
mkdir -p .claude
cp ~/.claude/agents/_templates/project-orchestrator.md .claude/orchestrator.md

# Customize with project context
vi .claude/orchestrator.md
```

The orchestrator should include:
- Project overview and tech stack
- Available specialists for delegation
- Project-specific standards
- Business rules and constraints

## Adding New Specialists

```bash
# Create new specialist
vi ~/.claude/agents/data-migration-expert.md

# Follow naming convention
# Update AGENT_REGISTRY.md

# Automatically in source control!
cd ~/repos/cdc/cdc-devtools
git add -A
git commit -m "Add data migration expert agent"
git push
```

## Example: Multi-Agent Workflow

### Project Orchestrator delegates:
```markdown
Task: Design and implement user analytics system

1. data-snowflake-architect-pro.md:
   - Design analytics schema
   - Optimize for query patterns

2. code-systems-engineer.md:
   - Build data ingestion service
   - Create API endpoints

3. test-data-integrity.md:
   - Validate data quality
   - Create test scenarios

4. doc-technical-writer.md:
   - Document the system
   - Create user guides
```

### Benefits
- **Reusability**: Specialists work across projects
- **Consistency**: Same expert knowledge everywhere
- **Maintainability**: Single source of truth
- **Scalability**: Easy to add new specialists
- **Version Control**: All changes tracked

## Best Practices

1. **Keep Specialists Focused**: Each agent should have one clear expertise
2. **Project Context in Orchestrators**: Specialists are generic; orchestrators are specific
3. **Clear Delegation**: Orchestrators should give specialists clear, bounded tasks
4. **Update Registry**: Keep `AGENT_REGISTRY.md` current with all agents

## Integration with Claude

### Manual Usage
1. Copy agent content from `~/.claude/agents/[agent].md`
2. Paste into Claude.ai
3. Add your specific requirements

### API Usage
```python
# Load specialist
with open(os.path.expanduser('~/.claude/agents/data-architect.md')) as f:
    specialist = f.read()

# Use with API
response = claude_client.complete(
    prompt=f"{specialist}\n\nTask: {user_task}",
    max_tokens=4000
)
```

### VS Code Extension
The Claude VS Code extension can access agents from:
- `~/.claude/agents/` - Global specialists
- `.claude/` - Project-specific orchestrators

## Troubleshooting

### "Agent not found"
- Check the symlink: `ls -la ~/.claude/agents`
- Ensure you're using correct naming: `category-role.md`

### "Orchestrator missing context"
- Each project needs its own orchestrator
- Copy from `_templates/project-orchestrator.md`

### Updates not showing
- Pull latest from CDC DevTools
- The symlink automatically reflects updates

## Contributing

To contribute new agents:
1. Follow naming convention in `NAMING_CONVENTION.md`
2. Use templates from `_templates/`
3. Update `AGENT_REGISTRY.md`
4. Submit PR to CDC DevTools

For questions, ask in #ai-agents Slack channel.