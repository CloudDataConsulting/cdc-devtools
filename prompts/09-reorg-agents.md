# Fix and Optimize Claude Agents - Focused Task

Please complete the agent organization by fixing the remaining issues with the imported agents.

## Current Location
The agents are currently in: `ai-agents/claude-prompts/`

## Task 0: Rename Folders for Clarity

First, let's use better folder names:

```bash
# Rename claude-prompts to claude-agents (more descriptive)
mv ai-agents/claude-prompts ai-agents/claude-agents

# Move and rename templates folder
mv ai-agents/claude-agents/templates ai-agents/claude-agent-templates
```

## Task 1: Verify Templates Are Separated

Ensure templates are NOT inside the claude-agents folder:

```bash
# Verify structure
tree ai-agents -L 2
# Should show:
# ai-agents/
# ├── claude-agents/          (contains only actual agents)
# ├── claude-agent-templates/ (contains templates, NOT inside claude-agents)
# └── [other folders]
```

## Task 2: Fix Naming Consistency

For each agent file in `ai-agents/claude-agents/`, ensure the internal name EXACTLY matches the filename (without .md):

### File naming pattern:
`category-specific-role.md`

### Internal naming pattern:
```markdown
# category-specific-role
```

### Examples:
- File: `data-architect.md` → Internal: `# data-architect`
- File: `devops-terraform.md` → Internal: `# devops-terraform`
- File: `code-reviewer.md` → Internal: `# code-reviewer`

### For each file:
1. Check the first line (title/name)
2. Update it to EXACTLY match the filename (minus .md extension)
3. Keep the hyphens and lowercase
4. Also update any self-references in the agent description to match

## Task 3: Set Up Symlink

After all agents are cleaned up:

```bash
# Backup current ~/.claude/agents if it exists
if [ -d ~/.claude/agents ]; then
    mv ~/.claude/agents ~/.claude/agents.backup-$(date +%Y%m%d-%H%M%S)
fi

# Create symlink (using new folder name)
ln -s $(pwd)/ai-agents/claude-agents ~/.claude/agents

# Verify
ls -la ~/.claude/agents
echo "Total agents available: $(ls ~/.claude/agents/*.md | wc -l)"
```

## Task 4: Create Summary

After completing all tasks, provide a summary:
- How many agents were processed in claude-agents/
- How many templates were moved to claude-agent-templates/
- Confirmation that symlink is working (claude-agents → ~/.claude/agents)

## Task 5: Update README References

Update any README files to reflect the new naming:

```bash
# Update ai-agents/README.md to reference:
# - claude-agents/ (not claude-prompts/)
# - claude-agent-templates/ (not templates/)

# Update any documentation that references the old names
```

## Do NOT handle these yet:
- MCP configuration
- Access levels
- Team onboarding
- Other optimizations

Just focus on getting the agents clean, consistent, and properly linked.
