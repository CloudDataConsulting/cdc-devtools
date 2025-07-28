# Hybrid Agent Workflow Guide

This document explains how to use CDC agents in both manual (copy-paste) and Claude Code (automatic) modes.

## Two Working Systems

### 1. Manual System (Original)
**Location**: `ai-agents/claude-agents/*.md`
**Usage**: Copy content → Paste into Claude.ai interface
**Best for**: Interactive sessions, exploration, custom modifications

### 2. Claude Code System (New)
**Location**: `.claude/agents/*.md`
**Usage**: Automatic discovery via Claude Code's agent system
**Best for**: Integrated development, consistent workflows, team collaboration

## Quick Reference

### Manual Usage (Existing Workflow)
```bash
# Browse available agents
cat claude-agents/AGENT_REGISTRY.md

# Copy an agent
cat claude-agents/data-architect.md

# Paste into Claude.ai and add your requirements
```

### Claude Code Usage (New Capability)
```bash
# Automatic: Claude Code discovers agents automatically
# No manual copying needed

# Explicit invocation: 
"Use the data-architect subagent to design my database schema"

# Proactive: Claude Code will suggest relevant agents
# based on your task and trigger phrases
```

## Agent Conversion

Agents have been converted with these key changes:

### Format Changes
- **Before**: YAML frontmatter with user examples
- **After**: Claude-focused trigger descriptions
- **Added**: Tool restrictions for security

### Description Transformation
- **Before**: "Use this agent when you need to..."
- **After**: "Expert [role]. Use proactively when... MUST BE USED when..."
- **Focus**: From user behavior → Claude invocation logic

### Tool Security
```yaml
# Example: Data agents
tools: Bash, Read, Write, Edit, Glob, Grep

# Example: Security agents (no Bash)
tools: Read, Edit, Glob, Grep
```

## Best Practices

### When to Use Manual vs Claude Code

**Use Manual System When:**
- Exploring new agent capabilities
- Customizing agents for specific projects
- Working outside Claude Code environment
- Need detailed examples and methodology

**Use Claude Code System When:**
- Integrated development workflows
- Want automatic agent suggestions
- Team collaboration with consistent agents
- Production development environments

### Maintaining Both Systems

1. **Source of Truth**: `claude-agents/` remains the authoritative source
2. **Conversion**: Use `scripts/convert-to-claude-code.py` to update Claude Code agents
3. **Updates**: Modify original agents, then re-convert
4. **Testing**: Test agents in both systems before team deployment

## Examples

### Manual Workflow Example
```bash
# 1. Find agent
ls claude-agents/

# 2. Read agent content
cat claude-agents/software-engineer-python.md

# 3. Copy to clipboard and paste in Claude.ai
# 4. Add your specific requirements
```

### Claude Code Workflow Example
```bash
# Claude Code automatically suggests agents based on context

User: "I need to design a Snowflake schema for customer analytics"
Claude: "I'll use the data-architect subagent to help design your schema..."

# Or explicit invocation:
User: "Use the data-architect subagent to design this schema"
```

## Troubleshooting

### "Agent not found in Claude Code"
- Check `.claude/agents/` directory exists
- Verify agent file format (YAML frontmatter)
- Run conversion script if agent was recently added

### "Manual agent content outdated"
- Original agents in `claude-agents/` are always current
- Claude Code agents are generated, may need regeneration

### "Agent doesn't trigger automatically"
- Check description contains proper trigger phrases
- Use explicit invocation: "Use the [agent-name] subagent..."
- Verify tool permissions match task requirements

## Conversion Script Usage

```bash
# Convert all agents
python3 scripts/convert-to-claude-code.py

# The script:
# 1. Reads from claude-agents/*.md
# 2. Converts format and descriptions
# 3. Outputs to .claude/agents/*.md
# 4. Preserves original content while optimizing for Claude Code
```

## Migration Path

1. **Current State**: Manual system works perfectly
2. **Hybrid Phase**: Both systems available (current implementation)
3. **Team Adoption**: Gradually adopt Claude Code agents
4. **Future**: Potentially consolidate based on team preference

This hybrid approach ensures no disruption to existing workflows while enabling new Claude Code capabilities.