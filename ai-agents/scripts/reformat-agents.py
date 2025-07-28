#!/usr/bin/env python3
"""
Reformat all Claude Code agents to include name first, description, color, then tools.
"""

import yaml
from pathlib import Path
import re

class AgentReformatter:
    """Reformats Claude Code agents with proper field ordering and colors."""
    
    def __init__(self, agents_dir: str, source_dir: str):
        self.agents_dir = Path(agents_dir)
        self.source_dir = Path(source_dir)
        
        # Color mapping from source files
        self.color_mapping = {
            'analytics-engineer': 'yellow',
            'change-management': 'purple',
            'core-orchestrator': 'yellow',
            'data-architect': 'blue',
            'data-engineer': 'blue',
            'devops-engineer-aws': 'orange',
            'devops-engineer-azure': 'blue',
            'devops-engineer-gcp': 'green',
            'devops-engineer-snowflake': 'cyan',
            'infrastructure-engineer-aws': 'blue',
            'infrastructure-engineer-azure': 'blue',
            'infrastructure-engineer-gcp': 'blue',
            'infrastructure-engineer-snowflake': 'cyan',
            'project-manager': 'orange',
            'risk-specialist': 'red',
            'security-compliance-engineer': 'red',
            'software-engineer-mcp': 'orange',
            'software-engineer-python': 'green',
            'software-engineer-rag': 'green',
            'software-engineer-streamlit': 'green',
            'software-engineer-web': 'purple',
            'technical-writer': 'purple',
            'terraform-iac-architect': 'blue',
            'test-data-integrity': 'red',
            'training-specialist': 'purple'
        }
    
    def reformat_agent(self, agent_file: Path) -> bool:
        """Reformat a single agent file."""
        try:
            print(f"Reformatting {agent_file.name}...")
            
            with open(agent_file, 'r') as f:
                content = f.read()
            
            # Parse current frontmatter and body
            if not content.startswith('---'):
                print(f"Warning: {agent_file.name} doesn't have frontmatter")
                return False
                
            parts = content.split('---', 2)
            if len(parts) < 3:
                print(f"Warning: Invalid frontmatter in {agent_file.name}")
                return False
                
            # Parse existing frontmatter
            try:
                current_frontmatter = yaml.safe_load(parts[1])
            except yaml.YAMLError as e:
                print(f"Error parsing YAML in {agent_file.name}: {e}")
                return False
                
            body = parts[2].strip()
            
            # Get agent name
            agent_name = agent_file.stem
            
            # Create new frontmatter with proper ordering
            new_frontmatter = {
                'name': current_frontmatter.get('name', agent_name),
                'description': current_frontmatter.get('description', ''),
                'color': self.color_mapping.get(agent_name, 'blue'),
                'tools': current_frontmatter.get('tools', 'Read, Write, Edit, Glob, Grep')
            }
            
            # Write reformatted file
            with open(agent_file, 'w') as f:
                f.write('---\n')
                yaml.dump(new_frontmatter, f, default_flow_style=False, sort_keys=False)
                f.write('---\n\n')
                f.write(body)
            
            print(f"✓ Reformatted {agent_file.name}")
            return True
            
        except Exception as e:
            print(f"✗ Error reformatting {agent_file.name}: {e}")
            return False
    
    def reformat_all(self) -> dict:
        """Reformat all agents."""
        stats = {'success': 0, 'failed': 0}
        
        agent_files = list(self.agents_dir.glob('*.md'))
        
        print(f"Reformatting {len(agent_files)} agents...")
        print("-" * 50)
        
        for agent_file in sorted(agent_files):
            if self.reformat_agent(agent_file):
                stats['success'] += 1
            else:
                stats['failed'] += 1
        
        print("-" * 50)
        print(f"Reformatting complete:")
        print(f"  ✓ Success: {stats['success']}")
        print(f"  ✗ Failed:  {stats['failed']}")
        print(f"  Total:     {len(agent_files)}")
        
        return stats

def main():
    """Main reformatting process."""
    agents_dir = "../.claude/agents"
    source_dir = "../claude-agents"
    
    print("Claude Code Agent Reformatter")
    print("=============================")
    print(f"Target: {agents_dir}")
    print()
    
    reformatter = AgentReformatter(agents_dir, source_dir)
    stats = reformatter.reformat_all()
    
    if stats['success'] > 0:
        print(f"\n✓ Successfully reformatted {stats['success']} agents!")
        print("New format:")
        print("  1. name (first)")
        print("  2. description") 
        print("  3. color (from source files)")
        print("  4. tools (last)")

if __name__ == "__main__":
    main()