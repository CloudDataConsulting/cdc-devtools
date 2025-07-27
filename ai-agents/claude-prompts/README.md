# CDC Claude Agent Prompts

This directory contains reusable Claude agent prompts optimized for Cloud Data Consulting projects. These agents represent specialized expertise that can be invoked through Claude's interface or API.

## Quick Start

### Using an Agent

1. **Browse the Registry**: Check `AGENT_REGISTRY.md` for available agents
2. **Select an Agent**: Choose based on your task requirements
3. **Copy the Prompt**: Get the agent file from the appropriate category
4. **Customize if Needed**: Add project-specific context
5. **Use with Claude**: Paste into Claude.ai or use with API

### Example Usage

```markdown
# In Claude.ai or API:
1. Copy contents of `data-agents/snowflake-architect-pro.md`
2. Add your specific requirements
3. Claude will respond as the specialized agent
```

## Directory Structure

```
claude-prompts/
├── core-agents/        # General-purpose agents
├── data-agents/        # Data engineering specialists
├── devops-agents/      # Infrastructure and deployment
├── templates/          # Templates for new agents
└── AGENT_REGISTRY.md   # Complete agent catalog
```

## Agent Categories

### Core Agents
Universal agents useful across all project types:
- **Orchestrator**: Coordinates multi-agent workflows
- **Doc Writer**: Creates technical documentation
- **Systems Engineer**: Builds production Python systems

### Data Agents
Specialized for data engineering and analytics:
- **Snowflake Architects**: Database design and optimization
- **RAG Architect**: AI-powered data retrieval systems
- **Data QA Engineer**: Ensures data integrity
- **Streamlit Builder**: Creates data applications

### DevOps Agents
Infrastructure and deployment specialists:
- **AWS/Snowflake DevOps**: Terraform and IaC expert
- **Storage Optimizer**: Cloud storage efficiency
- **Security Engineer**: Compliance and security

## Customization Guide

### Adding Project Context

```markdown
# Original agent prompt
You are an expert Snowflake architect...

# Add your context after:
## Project Context
- Client: [Client Name]
- Environment: [Dev/Staging/Prod]
- Specific Requirements: [List requirements]
- Constraints: [Any limitations]
```

### Modifying Output Format

Agents can be customized to match your preferred output:

```markdown
## Custom Output Format
Please provide responses in the following structure:
1. Summary (2-3 sentences)
2. Detailed explanation
3. Code examples
4. Next steps
```

### Combining Agents

For complex projects, use multiple agents in sequence:

```markdown
1. Start with snowflake-architect-pro for design
2. Switch to aws-snowflake-devops for deployment
3. Use data-integrity-qa-engineer for validation
4. Finish with tech-docs-writer for documentation
```

## Best Practices

### 1. Agent Selection
- **Start Specific**: Use the most specialized agent for your task
- **Check Registry**: Review capabilities in `AGENT_REGISTRY.md`
- **Consider Combinations**: Some tasks benefit from multiple agents

### 2. Context Provision
- **Be Explicit**: Provide clear project requirements
- **Include Constraints**: Mention any limitations upfront
- **Share Examples**: Give examples of desired outputs

### 3. Iterative Refinement
- **Start Simple**: Begin with basic agent capabilities
- **Add Complexity**: Layer in additional requirements
- **Save Customizations**: Keep successful modifications

### 4. Version Control
```bash
# Track agent customizations in your project
project/
├── .claude/
│   ├── agents/
│   │   ├── customized-architect.md
│   │   └── project-specific-qa.md
│   └── README.md
```

## Creating New Agents

### Using Templates

1. Start with `templates/agent-template.md` for comprehensive agents
2. Use `templates/basic-agent.md` for focused, simple agents
3. Follow the structure but adapt to your needs

### Agent Components

Every agent should include:
- **Metadata**: Name, description, use cases
- **Role Definition**: Clear statement of expertise
- **Core Principles**: Guiding philosophy
- **Methodology**: Step-by-step approach
- **Output Standards**: Expected deliverables

### Testing New Agents

Before adding to the registry:
1. Test with real project scenarios
2. Verify output quality and consistency
3. Get feedback from team members
4. Document successful use cases

## Integration with Projects

### Project Structure
```
your-project/
├── .claude/
│   ├── agents/           # Project-specific agents
│   ├── prompts/          # Common prompts
│   └── context.md        # Project context
├── src/
└── docs/
```

### Workflow Integration

1. **Development Phase**: Use systems-engineer for code
2. **Testing Phase**: Use qa-engineer for validation
3. **Documentation Phase**: Use doc-writer for guides
4. **Deployment Phase**: Use devops agents for release

## Advanced Usage

### API Integration

```python
import anthropic

# Load agent prompt
with open('data-agents/snowflake-architect-pro.md', 'r') as f:
    agent_prompt = f.read()

# Use with API
client = anthropic.Client(api_key="...")
response = client.completions.create(
    prompt=f"{agent_prompt}\n\nUser: {user_request}",
    model="claude-3-opus-20240229",
    max_tokens=4000
)
```

### Batch Processing

For multiple related tasks:
```python
agents = {
    'design': 'snowflake-architect-pro.md',
    'implement': 'python-systems-engineer.md',
    'test': 'data-integrity-qa-engineer.md',
    'document': 'tech-docs-writer.md'
}

for phase, agent_file in agents.items():
    # Process each phase with appropriate agent
    pass
```

## Metrics and Improvement

### Track Usage
- Which agents are used most frequently
- Common customizations needed
- Success rates for different tasks

### Gather Feedback
- Team satisfaction with agent outputs
- Time saved using agents
- Quality improvements observed

### Continuous Improvement
- Update agents based on new best practices
- Add new agents for emerging needs
- Refine based on team feedback

## Contributing

To contribute new agents or improvements:

1. Follow the template structure
2. Test thoroughly with real scenarios
3. Document use cases and examples
4. Submit PR with:
   - Agent file in correct category
   - Registry update
   - Example usage
   - Test results

## Support

- **Questions**: Ask in #ai-agents Slack channel
- **Issues**: Report in GitHub issues
- **Improvements**: Submit PRs with enhancements
- **Training**: Request agent training sessions