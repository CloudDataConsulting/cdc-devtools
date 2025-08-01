# CDC Claude Agents - Usage Pattern

This directory contains reusable specialist agents that are symlinked to `~/.claude/agents/` for easy access across all projects.

## Setting Up the Symbolic Link

### What is a Symbolic Link?

A symbolic link (or "symlink") is a special type of file that points to another file or directory. Think of it as a shortcut or alias:
- It acts like the original file/directory but doesn't duplicate the content
- Changes to files in either location are immediately reflected in both
- Deleting the symlink doesn't delete the original files
- It's like having the same folder accessible from multiple locations

### Why Use a Symlink for Claude Agents?

This setup provides several benefits:
1. **Centralized Management**: All agents are maintained in the CDC DevTools repository
2. **Automatic Updates**: When you pull the latest changes from git, your `~/.claude/agents/` automatically has the updates
3. **Version Control**: All agent changes are tracked in git
4. **Claude Code Integration**: Claude Code automatically discovers agents in `~/.claude/agents/`
5. **Cross-Project Access**: Same agents available for all your projects

### How to Set Up the Symlink

```bash
# 1. Remove any existing ~/.claude/agents directory (backup first if needed)
rm -rf ~/.claude/agents

# 2. Create the .claude directory if it doesn't exist
mkdir -p ~/.claude

# 3. Create the symbolic link
ln -s ~/repos/cdc/cdc-devtools/ai-agents/claude-agents ~/.claude/agents

# 4. Verify the symlink was created correctly
ls -la ~/.claude/
# Should show: agents -> /Users/[your-username]/repos/cdc/cdc-devtools/ai-agents/claude-agents
```

### Verifying Your Setup

```bash
# Check that the symlink points to the right location
readlink ~/.claude/agents
# Output: /Users/[your-username]/repos/cdc/cdc-devtools/ai-agents/claude-agents

# List agents to confirm access
ls ~/.claude/agents/
# Should show all the .md agent files

# Test reading an agent
cat ~/.claude/agents/data-architect.md
# Should display the agent content
```

### Troubleshooting

**"No such file or directory" error:**
- Ensure CDC DevTools is cloned to `~/repos/cdc/cdc-devtools`
- Check the path: `ls ~/repos/cdc/cdc-devtools/ai-agents/claude-agents`

**Symlink points to wrong location:**
```bash
# Remove incorrect symlink
rm ~/.claude/agents
# Recreate with correct path
ln -s ~/repos/cdc/cdc-devtools/ai-agents/claude-agents ~/.claude/agents
```

**Permission issues:**
- Ensure you have read permissions on the CDC DevTools repository
- The symlink itself needs only read permissions

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
cat ~/.claude/agents/data-architect.md

# Copy into Claude.ai and use
```

### Project Workflow
```markdown
1. Project has its own orchestrator in `.claude/orchestrator.md`
2. Orchestrator understands the request
3. Orchestrator delegates to specialists:
   - "Use data-architect.md for schema design"
   - "Use software-engineer-python.md for implementation"
4. Orchestrator synthesizes results for project context
```

## Flat Structure

All agents follow the naming convention `[category]-[role].md`:

```
~/.claude/agents/
├── analytics-engineer.md         # Analytics and dimensional modeling
├── change-management.md          # Database change management
├── core-orchestrator.md          # Multi-domain project coordination
├── crypto-coin-analyzer.md       # Cryptocurrency analysis
├── crypto-market-analyst.md      # Crypto market analysis
├── data-architect.md             # Data architecture and modeling
├── data-engineer.md              # Data pipeline development
├── devops-engineer-aws.md        # AWS DevOps automation
├── devops-engineer-azure.md      # Azure DevOps automation
├── devops-engineer-gcp.md        # GCP DevOps automation
├── devops-engineer-snowflake.md  # Snowflake DevOps automation
├── hello-world-agent.md          # Simple greeting agent
├── infrastructure-engineer-aws.md     # AWS infrastructure
├── infrastructure-engineer-azure.md   # Azure infrastructure
├── infrastructure-engineer-gcp.md     # GCP infrastructure
├── infrastructure-engineer-snowflake.md # Snowflake infrastructure
├── meta-agent.md                 # Agent creation and optimization
├── project-manager.md            # Project planning and management
├── proposal-writer.md            # Business proposals and RFPs
├── risk-specialist.md            # Risk assessment and mitigation
├── security-compliance-engineer.md    # Security and compliance
├── software-engineer-mcp.md      # MCP server development
├── software-engineer-python.md   # Python system architecture
├── software-engineer-rag.md      # RAG system development
├── software-engineer-streamlit.md     # Streamlit applications
├── software-engineer-web.md      # Web development
├── tdd-python-expert.md          # Test-driven Python development
├── technical-writer.md           # Technical documentation
├── terraform-iac-architect.md    # Terraform and IaC design
├── test-data-integrity.md        # Data quality testing
└── training-specialist.md        # Training material development
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

1. data-architect.md:
   - Design analytics schema
   - Optimize for query patterns

2. data-engineer.md:
   - Build data ingestion pipelines
   - Create ELT processes

3. test-data-integrity.md:
   - Validate data quality
   - Create test scenarios

4. technical-writer.md:
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