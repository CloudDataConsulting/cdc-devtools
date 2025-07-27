# Setup Flat Agent Structure with Proper Naming Convention

Please reorganize the imported Claude agents into a single flat directory with a clear naming convention, then set up symlinks for easy access.

## 1. Reorganize to Flat Structure

Move all agents from subdirectories into a single flat structure in CDC DevTools:

```
ai-agents/claude-prompts/
├── README.md
├── NAMING_CONVENTION.md      # Document the naming rules
├── code-reviewer.md          # Code quality agents
├── code-test-writer.md
├── data-architect.md         # Data engineering agents
├── data-sql-optimizer.md
├── data-etl-developer.md
├── devops-terraform.md       # DevOps agents
├── devops-aws-architect.md
├── doc-technical-writer.md   # Documentation agents
├── doc-api-documenter.md
└── _templates/               # Keep templates in subdirectory
    ├── basic-agent.md
    └── specialist-agent.md
```

## 2. Naming Convention

Document this in `NAMING_CONVENTION.md`:

```markdown
# CDC Agent Naming Convention

All reusable agents follow this pattern:
`[category]-[specific-role].md`

## Categories:
- `code-` : Code writing, reviewing, refactoring
- `data-` : Data engineering, SQL, analytics
- `devops-` : Infrastructure, deployment, CI/CD
- `doc-` : Documentation, technical writing
- `security-` : Security analysis, compliance
- `test-` : Testing strategies, test writing
- `api-` : API design and integration

## Examples:
- `code-reviewer.md` - Reviews code for quality
- `data-architect.md` - Designs data systems
- `devops-terraform.md` - Terraform specialist

## Special Files:
- `_templates/` - Templates for creating new agents
- NO orchestrator here - each project has its own
```

## 3. Update Agent Files

When renaming files, also update internal references:

### Check for these common patterns:
```markdown
# If file was "orchestrator.md" becoming "core-orchestrator.md"

# Update title/header
OLD: # Orchestrator
NEW: # Core-Orchestrator

# Update any self-references
OLD: Agent: orchestrator
NEW: Agent: core-orchestrator

# Update any "I am" statements
OLD: I am an orchestrator agent
NEW: I am a core-orchestrator agent

# Update any function/role declarations
OLD: Role: orchestrator
NEW: Role: core-orchestrator
```

### Ensure each file has consistent naming:
```markdown
# [Category]-[Role] Agent

**Agent Name**: [category]-[role]  # Must match filename!
**Category**: [code|data|devops|doc|security|test|api]
**Specialization**: [Specific expertise]
**Best Used By**: Project orchestrators needing [specific skill]

## Role
[Clear one-sentence description]

## Expertise
[...]
```

### Search and Replace Pattern:
For each file being renamed from `oldname.md` to `category-newname.md`:
1. Search for: `oldname` (case-insensitive)
2. Replace with: `category-newname`
3. Check for variations: "Oldname", "OLDNAME", "old_name"

## 4. Set Up Symlink

After reorganizing, create the symlink:

```bash
# Backup existing directory if needed
if [ -d ~/.claude/agents ]; then
    mv ~/.claude/agents ~/.claude/agents.backup-$(date +%Y%m%d)
fi

# Create parent directory if needed
mkdir -p ~/.claude

# Create symlink
ln -s ~/repos/cdc-devtools/ai-agents/claude-prompts ~/.claude/agents

# Verify
ls -la ~/.claude/agents
```

## 5. Create Project Orchestrator Template

Since orchestrators are project-specific, create a template in `_templates/project-orchestrator.md`:

```markdown
# Project Orchestrator - [PROJECT NAME]

## Project Context
[Project-specific information that this orchestrator needs]

## Available Specialists
You can delegate to these specialist agents:
- code-reviewer.md - For code quality checks
- data-architect.md - For data design decisions
- devops-terraform.md - For infrastructure tasks
[List relevant agents for this project]

## Project-Specific Instructions
[Any special rules or patterns for this project]

## Workflow
1. Understand the request
2. Break down into specialist tasks
3. Delegate to appropriate agents
4. Synthesize results
5. Ensure project standards are met
```

## 6. Document Usage Pattern

Update the main README to explain the pattern:

```markdown
# CDC Claude Agents - Usage Pattern

## Two-Tier System

### 1. Reusable Specialist Agents (This Repository)
- Live in `~/.claude/agents/` (symlinked to CDC DevTools)
- Named by category and specialization
- Used across all projects
- Under source control

### 2. Project Orchestrators (Individual Projects)
- Live in each project directory
- Know project-specific context
- Delegate to specialist agents
- Coordinate multi-agent workflows

## Example Workflow

1. Project has its own `orchestrator.md`
2. Orchestrator understands request
3. Orchestrator delegates to specialists:
   - "Use data-architect.md for schema design"
   - "Use code-reviewer.md for PR review"
4. Orchestrator synthesizes results

## Adding New Agents

```bash
# Create new specialist
vi ~/.claude/agents/data-migration-expert.md

# Automatically in source control!
cd ~/repos/cdc-devtools
git add -A
git commit -m "Add data migration expert agent"
git push
```
```

## 7. Migration Script

Create `migrate-to-flat.sh` to help flatten existing structures AND update internal references:

```bash
#!/bin/bash
# Flatten subdirectory structure and update internal references

cd ai-agents/claude-prompts

# Function to update internal references
update_internal_refs() {
    local file=$1
    local old_name=$2
    local new_name=$3

    # Create case variations
    old_lower=$(echo "$old_name" | tr '[:upper:]' '[:lower:]')
    old_upper=$(echo "$old_name" | tr '[:lower:]' '[:upper:]')
    old_title=$(echo "$old_name" | sed 's/.*/\u&/')

    new_lower=$(echo "$new_name" | tr '[:upper:]' '[:lower:]')
    new_upper=$(echo "$new_name" | tr '[:lower:]' '[:upper:]')
    new_title=$(echo "$new_name" | sed 's/.*/\u&/')

    # Update file content
    sed -i.bak \
        -e "s/${old_lower}/${new_lower}/g" \
        -e "s/${old_upper}/${new_upper}/g" \
        -e "s/${old_title}/${new_title}/g" \
        -e "s/${old_name}/${new_name}/g" \
        "$file"

    # Remove backup
    rm "${file}.bak"
}

# Move all .md files from subdirectories to current directory
find . -mindepth 2 -name "*.md" -type f | while read file; do
    # Extract category from directory name
    category=$(dirname "$file" | cut -d'/' -f2 | sed 's/-agents$//')
    filename=$(basename "$file")
    basename_no_ext="${filename%.md}"

    # Determine new name
    if [[ ! "$filename" =~ ^[a-z]+-.*\.md$ ]]; then
        newname="${category}-${filename}"
        newbase="${category}-${basename_no_ext}"
    else
        newname="$filename"
        newbase="$basename_no_ext"
    fi

    # Copy file to new location
    cp "$file" "./$newname"

    # Update internal references
    update_internal_refs "./$newname" "$basename_no_ext" "$newbase"

    echo "Migrated: $file -> $newname (updated internal refs)"
done

# Remove empty directories
find . -mindepth 1 -type d -empty -delete

echo "Migration complete! Check the updated files for accuracy."
```

## Summary

This creates a clean, flat structure where:
- All reusable agents are in one directory
- Clear naming shows agent purpose
- Easy to add new agents
- Each project has its own orchestrator
- Everything under source control

The 20-30 agents you may have will be easily manageable with the category prefix naming!
