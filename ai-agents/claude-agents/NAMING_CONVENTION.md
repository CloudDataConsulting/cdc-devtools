# CDC Agent Naming Convention

All reusable agents follow a consistent pattern that makes their purpose immediately clear.

## Pattern

```
[category]-[specific-role].md
```

## Categories

### `code-`
Code writing, reviewing, refactoring, and development
- Examples: `code-reviewer.md`, `code-systems-engineer.md`, `code-streamlit-builder.md`

### `data-`
Data engineering, SQL, analytics, and data architecture
- Examples: `data-architect.md`, `data-snowflake-architect-pro.md`, `data-migration-expert.md`

### `devops-`
Infrastructure, deployment, CI/CD, and cloud operations
- Examples: `devops-terraform.md`, `devops-aws-architect.md`, `devops-cloud-storage-optimizer.md`

### `doc-`
Documentation, technical writing, and content creation
- Examples: `doc-technical-writer.md`, `doc-api-documenter.md`, `doc-readme-creator.md`

### `security-`
Security analysis, compliance, and vulnerability assessment
- Examples: `security-compliance-engineer.md`, `security-auditor.md`, `security-penetration-tester.md`

### `test-`
Testing strategies, test writing, and quality assurance
- Examples: `test-automation-engineer.md`, `test-data-integrity.md`, `test-performance-analyst.md`

### `api-`
API design, integration, and development
- Examples: `api-designer.md`, `api-integration-specialist.md`, `api-graphql-expert.md`

### `core-`
Fundamental agents that coordinate or provide essential services
- Examples: `core-orchestrator.md`, `core-analyzer.md`

## Special Files and Directories

### `_templates/`
Templates for creating new agents
- `basic-agent.md` - Simple agent template
- `specialist-agent.md` - Comprehensive agent template
- `project-orchestrator.md` - Template for project-specific orchestrators

### `AGENT_REGISTRY.md`
Complete catalog of all available agents with descriptions

### `NAMING_CONVENTION.md`
This file - documents the naming standards

### `README.md`
Usage guide and overview of the agent system

## Important Notes

### NO Generic Orchestrator
- Each project should have its own orchestrator with project-specific context
- Use `_templates/project-orchestrator.md` as a starting point

### Agent File Structure
Each agent file must include:

```markdown
---
name: [category]-[specific-role]  # Must match filename!
description: [Clear one-line description]
color: [color for Claude UI]
---

# [Category]-[Specific Role] Agent

**Agent Name**: [category]-[specific-role]
**Category**: [category from list above]
**Specialization**: [Specific expertise area]
```

### Adding New Agents

1. Choose the appropriate category prefix
2. Use lowercase with hyphens (no underscores or camelCase)
3. Be specific about the role
4. Update `AGENT_REGISTRY.md` after adding

### Examples of Good Names

✅ Good:
- `data-warehouse-architect.md`
- `code-python-optimizer.md`
- `security-gdpr-compliance.md`

❌ Avoid:
- `architect.md` (too generic)
- `DataWarehouse.md` (wrong case)
- `python_code_reviewer.md` (uses underscores)

## Migration from Old Structure

If you have agents in subdirectories:
1. Run `./migrate-to-flat.sh` to flatten the structure
2. Review the renamed files
3. Update any project references to the new names

## Benefits of This Convention

1. **Discoverability**: Easy to find agents by category
2. **Clarity**: Purpose is clear from the filename
3. **Consistency**: All agents follow the same pattern
4. **Simplicity**: Flat structure is easier to browse
5. **Source Control**: Changes are easier to track