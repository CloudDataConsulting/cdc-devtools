# CDC Agent Naming Convention

All agents follow consistent patterns that make their purpose and expertise immediately clear.

## Naming Patterns

We use three main patterns based on the agent's role:

### 1. Role-Based Pattern
```
[role]-engineer-[specialty].md
```
Used for agents with specific engineering roles:
- **Software Engineers**: `software-engineer-python.md`, `software-engineer-rag.md`, `software-engineer-streamlit.md`
- **Infrastructure Engineers**: `infrastructure-engineer-aws.md`, `infrastructure-engineer-azure.md`, `infrastructure-engineer-gcp.md`, `infrastructure-engineer-snowflake.md`
- **DevOps Engineers**: `devops-engineer-aws.md`, `devops-engineer-azure.md`, `devops-engineer-gcp.md`, `devops-engineer-snowflake.md`

### 2. Simple Role Pattern
```
[role-description].md
```
Used for agents with unique, well-defined roles:
- `data-architect.md` - Database and data warehouse architecture
- `technical-writer.md` - Documentation and technical writing
- `terraform-iac-architect.md` - Infrastructure as Code architecture
- `security-compliance-engineer.md` - Security and compliance expertise
- `test-data-integrity.md` - Data validation and testing

### 3. Core System Pattern
```
core-[function].md
```
Used for fundamental system agents:
- `core-orchestrator.md` - Main orchestration agent

## Special Files and Directories

### `../claude-agent-templates/`
Templates for creating new agents (kept separate from active agents):
- `basic-agent.md` - Simple agent template
- `agent-template.md` - Comprehensive agent template
- `project-orchestrator.md` - Template for project-specific orchestrators

### `../claude-agents-archive/`
Archived agents that are no longer actively maintained

### `AGENT_REGISTRY.md`
Complete catalog of all available agents with descriptions

### `NAMING_CONVENTION.md`
This file - documents the naming standards

### `README.md`
Usage guide and overview of the agent system

## Agent File Structure

Each agent file must include:

```markdown
---
name: [agent-name]  # Must match filename without .md extension!
description: [Clear description of when to use this agent]
color: [color for Claude UI - blue, green, orange, cyan, etc.]
---

[Agent content with expertise and examples]
```

## Guidelines for New Agents

### Naming Rules
1. Use lowercase with hyphens (no underscores or camelCase)
2. Be specific about the role and expertise
3. Follow one of the three patterns above
4. Ensure the internal `name:` field matches the filename (without .md)
5. Update `AGENT_REGISTRY.md` after adding

### Choosing the Right Pattern

**Use Role-Based Pattern when:**
- The agent fits a standard engineering role (software, infrastructure, devops)
- There are multiple platform/language variants
- Example: `software-engineer-java.md`, `devops-engineer-kubernetes.md`

**Use Simple Role Pattern when:**
- The role is unique and well-understood
- No variants are needed
- Example: `data-architect.md`, `scrum-master.md`

**Use Core System Pattern when:**
- The agent provides system-level functionality
- It coordinates other agents
- Example: `core-orchestrator.md`

### Examples of Good Names

✅ **Good:**
- `software-engineer-golang.md` (follows role-based pattern)
- `data-architect.md` (simple, clear role)
- `infrastructure-engineer-aws.md` (platform-specific expertise)
- `technical-writer.md` (unique, well-defined role)

❌ **Avoid:**
- `engineer.md` (too generic)
- `AWSExpert.md` (wrong case)
- `python_software_engineer.md` (uses underscores)
- `code-writer-python-expert-senior.md` (too long, redundant)

## Benefits of This Convention

1. **Clarity**: Role and expertise are immediately obvious
2. **Consistency**: Predictable patterns make agents easy to find
3. **Scalability**: Easy to add new specialties within existing patterns
4. **Simplicity**: Flat structure with clear naming
5. **Flexibility**: Three patterns cover all use cases without over-complication