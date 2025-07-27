# Import and Organize Claude Agents into CDC DevTools

Please import my Claude agent prompt files and organize them properly within CDC DevTools, creating a clear structure that distinguishes between Claude agent prompts and Python agent frameworks.

## 1. Import Claude Agents

First, check both possible locations and import all agent files:
```bash
# Check both possible locations (case-sensitive)
~/.claude/agents/
~/.Claude/agents/
```

Copy all agent files (likely .md files) to CDC DevTools while preserving their names.

## 2. Reorganize ai-agents Directory

Create this improved structure:

```
ai-agents/
├── README.md                    # Updated to explain both types
├── claude-prompts/              # Claude agent instructions (NEW)
│   ├── README.md               # "How to use Claude agents"
│   ├── core-agents/            # Essential reusable agents
│   │   ├── orchestrator.md
│   │   ├── code-reviewer.md
│   │   ├── test-writer.md
│   │   └── doc-writer.md
│   ├── data-agents/            # Data-specific agents
│   │   ├── data-architect.md
│   │   ├── sql-optimizer.md
│   │   └── etl-developer.md
│   ├── devops-agents/          # Infrastructure agents
│   │   ├── terraform-expert.md
│   │   ├── aws-architect.md
│   │   └── security-reviewer.md
│   └── templates/              # Templates for new agents
│       ├── basic-agent.md
│       └── specialized-agent.md
├── python-framework/            # Rename base-agents to this
│   ├── __init__.py
│   ├── git_aware_agent.py     # (move existing files here)
│   ├── model_router.py
│   └── ... (other .py files)
├── config/                      # Keep as is
├── examples/                    # Keep as is
└── orchestrators/              # Keep as is
```

## 3. Categorize Imported Agents

As you import agents from `~/.claude/agents/`, organize them into categories:

### Core Agents (used frequently across projects)
- Orchestrator/coordinator agents
- Code review and quality agents
- Documentation agents
- Testing agents

### Data Agents (CDC specialties)
- Data architecture agents
- SQL/database agents
- ETL/pipeline agents
- Analytics agents

### DevOps Agents
- Infrastructure agents
- Deployment agents
- Security/compliance agents
- Monitoring agents

### Specialized Agents
- Client-specific patterns
- Industry-specific agents
- Experimental agents

If an agent doesn't clearly fit a category, put it in `claude-prompts/uncategorized/` for now.

## 4. Create Agent Registry

Create `ai-agents/claude-prompts/AGENT_REGISTRY.md`:

```markdown
# CDC Claude Agent Registry

## Core Agents

### Orchestrator
- **File**: `core-agents/orchestrator.md`
- **Purpose**: Coordinates multi-agent workflows
- **Best for**: Complex projects requiring multiple specialists
- **Key capabilities**: Task decomposition, agent selection, result synthesis

### Code Reviewer
- **File**: `core-agents/code-reviewer.md`
- **Purpose**: Reviews code for quality, security, and best practices
- **Best for**: PR reviews, code audits
- **Key capabilities**: [List key strengths]

[Continue for each agent...]

## Usage Patterns

### For New Projects
1. Start with orchestrator.md
2. Add specialized agents as needed

### For Data Projects
1. data-architect.md for design
2. sql-optimizer.md for queries
3. etl-developer.md for pipelines
```

## 5. Create Agent Template System

In `ai-agents/claude-prompts/templates/`, create:

### agent-template.md
```markdown
# [Agent Name]

## Role
[One sentence description of this agent's primary role]

## Expertise
- [Key area 1]
- [Key area 2]
- [Key area 3]

## Instructions
[Core instructions for the agent]

## Best Practices
[Specific guidelines this agent should follow]

## Output Format
[Expected format for agent responses]

## Examples
[Optional: Example interactions]
```

## 6. Add Usage Documentation

Create `ai-agents/claude-prompts/README.md`:

```markdown
# CDC Claude Agent Prompts

This directory contains reusable Claude agent prompts for CDC projects.

## Quick Start

1. Choose an agent from the registry
2. Copy the agent file to your project
3. Customize as needed
4. Use with Claude API or Claude.ai

## Agent Categories

- **Core Agents**: General purpose, used across all projects
- **Data Agents**: Specialized for data engineering tasks
- **DevOps Agents**: Infrastructure and deployment specialists
- **Templates**: Starting points for custom agents

## Customization

Agents can be customized by:
1. Adding project-specific context
2. Modifying expertise areas
3. Adjusting output formats
4. Adding domain knowledge

## Best Practices

1. Keep agent prompts focused on a single responsibility
2. Include clear output format specifications
3. Add examples when behavior needs to be precise
4. Version control customizations separately
```

## 7. Update Main ai-agents README

Update the existing `ai-agents/README.md` to clarify the two types:

```markdown
# CDC AI Agents

This directory contains two types of AI agent resources:

## 1. Claude Agent Prompts (`claude-prompts/`)
Pre-written instructions for Claude to act as specialized agents. These are:
- Markdown files with role definitions
- Ready to use with Claude API or UI
- Organized by specialty (data, devops, etc.)
- See `claude-prompts/AGENT_REGISTRY.md` for full list

## 2. Python Agent Framework (`python-framework/`)
