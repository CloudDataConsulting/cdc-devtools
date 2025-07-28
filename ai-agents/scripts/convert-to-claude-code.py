#!/usr/bin/env python3
"""
Convert CDC agents from manual format to Claude Code format.

This script transforms agents from the manual copy-paste format (with YAML frontmatter 
and user examples) to Claude Code's expected format (with Claude-focused descriptions
and tool restrictions).
"""

import re
import yaml
from pathlib import Path
from typing import Dict, List

class AgentConverter:
    """Converts CDC agents to Claude Code format."""
    
    def __init__(self, source_dir: str, target_dir: str):
        self.source_dir = Path(source_dir)
        self.target_dir = Path(target_dir)
        self.target_dir.mkdir(parents=True, exist_ok=True)
        
        # Tool mappings by agent category
        self.tool_mappings = {
            'data-': ['Bash', 'Read', 'Write', 'Edit', 'Glob', 'Grep'],
            'software-': ['Bash', 'Read', 'Write', 'Edit', 'Glob', 'Grep', 'MultiEdit'],
            'devops-': ['Bash', 'Read', 'Write', 'Edit', 'Glob', 'Grep'],
            'infrastructure-': ['Bash', 'Read', 'Write', 'Edit', 'Glob', 'Grep'],
            'security-': ['Read', 'Edit', 'Glob', 'Grep'],  # No Bash for security
            'core-': ['Bash', 'Read', 'Write', 'Edit', 'Glob', 'Grep'],
            'technical-': ['Read', 'Write', 'Edit', 'Glob', 'Grep'],
            'default': ['Read', 'Write', 'Edit', 'Glob', 'Grep']
        }
    
    def convert_description(self, original_desc: str, agent_name: str) -> str:
        """
        Convert user-focused description to Claude-focused trigger description.
        
        Transforms examples like:
        "Use this agent when you need..." 
        → "Expert [role]. Use proactively when... MUST BE USED when..."
        """
        # Extract the main role/expertise
        role_match = re.search(r'Use this agent when you need to (.+?)\.', original_desc)
        role = role_match.group(1) if role_match else "specialized assistant"
        
        # Extract key capabilities
        capabilities = self._extract_capabilities(original_desc)
        
        # Create Claude-focused description
        claude_desc = f"Expert {role}. Use this agent proactively when tasks involve {', '.join(capabilities[:3])}."
        
        # Add trigger phrases
        if 'data' in agent_name:
            claude_desc += " MUST BE USED when user mentions database design, ETL, or data modeling."
        elif 'software' in agent_name:
            claude_desc += " MUST BE USED when user needs code architecture, refactoring, or system design."
        elif 'devops' in agent_name:
            claude_desc += " MUST BE USED when user mentions deployment, infrastructure, or CI/CD."
        elif 'security' in agent_name:
            claude_desc += " MUST BE USED when user mentions security, compliance, or vulnerability analysis."
        else:
            claude_desc += f" MUST BE USED for {role} tasks."
            
        return claude_desc
    
    def _extract_capabilities(self, text: str) -> List[str]:
        """Extract key capabilities from description text."""
        # Simple keyword extraction - could be enhanced with NLP
        keywords = []
        capability_patterns = [
            r'(\w+ing)\s+\w+',  # "designing systems", "implementing features"
            r'(\w+\s+\w+)\s+(?:design|implementation|optimization)',
            r'(?:expertise in|specializes in|focuses on)\s+([^.]+)'
        ]
        
        for pattern in capability_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            keywords.extend(matches[:2])  # Limit to avoid overly long descriptions
            
        return keywords[:5] if keywords else ['specialized tasks']
    
    def get_tools_for_agent(self, agent_name: str) -> List[str]:
        """Determine appropriate tools based on agent category."""
        for category, tools in self.tool_mappings.items():
            if agent_name.startswith(category):
                return tools
        return self.tool_mappings['default']
    
    def convert_agent(self, source_file: Path) -> bool:
        """Convert a single agent file."""
        try:
            print(f"Converting {source_file.name}...")
            
            with open(source_file, 'r') as f:
                content = f.read()
            
            # Parse YAML frontmatter (handling embedded examples)
            if content.startswith('---'):
                parts = content.split('---', 2)
                if len(parts) >= 3:
                    # Extract just the basic fields, ignore complex examples
                    frontmatter_text = parts[1]
                    frontmatter = {}
                    
                    # Parse line by line to handle the non-standard format
                    for line in frontmatter_text.split('\n'):
                        line = line.strip()
                        if line and ':' in line and not line.startswith('<'):
                            key, value = line.split(':', 1)
                            key = key.strip()
                            value = value.strip()
                            
                            # Only take simple fields
                            if key in ['name', 'description', 'color']:
                                frontmatter[key] = value
                    
                    body = parts[2].strip()
                else:
                    print(f"Warning: Invalid frontmatter in {source_file.name}")
                    return False
            else:
                print(f"Warning: No frontmatter in {source_file.name}")
                return False
            
            # Extract key information
            name = frontmatter.get('name', source_file.stem)
            original_desc = frontmatter.get('description', '')
            
            # Convert description
            new_description = self.convert_description(original_desc, name)
            
            # Get appropriate tools
            tools = self.get_tools_for_agent(name)
            
            # Clean up body content
            cleaned_body = self._clean_body_content(body)
            
            # Create new frontmatter
            new_frontmatter = {
                'name': name,
                'description': new_description,
                'tools': ', '.join(tools)
            }
            
            # Write converted file
            target_file = self.target_dir / source_file.name
            with open(target_file, 'w') as f:
                f.write('---\n')
                yaml.dump(new_frontmatter, f, default_flow_style=False)
                f.write('---\n\n')
                f.write(cleaned_body)
            
            print(f"✓ Converted {source_file.name}")
            return True
            
        except Exception as e:
            print(f"✗ Error converting {source_file.name}: {e}")
            return False
    
    def _clean_body_content(self, body: str) -> str:
        """Clean and optimize the agent body content."""
        # Remove overly verbose sections
        body = re.sub(r'#### Discovery Resources.*?```\n```', '', body, flags=re.DOTALL)
        
        # Add security guidelines if not present
        if '**Security Guidelines:**' not in body:
            security_section = '''
**Security Guidelines:**
- Never execute destructive commands without explicit confirmation
- Use environment variables for all sensitive configuration
- Implement proper error handling and logging
'''
            # Insert before the last paragraph
            body = body.rstrip() + '\n' + security_section
        
        return body
    
    def convert_all(self) -> Dict[str, int]:
        """Convert all agents in the source directory."""
        stats = {'success': 0, 'failed': 0, 'skipped': 0}
        
        # Get all .md files except documentation files
        agent_files = [
            f for f in self.source_dir.glob('*.md') 
            if f.name not in ['README.md', 'AGENT_REGISTRY.md', 'NAMING_CONVENTION.md']
        ]
        
        print(f"Found {len(agent_files)} agent files to convert")
        print("-" * 50)
        
        for agent_file in agent_files:
            if self.convert_agent(agent_file):
                stats['success'] += 1
            else:
                stats['failed'] += 1
        
        print("-" * 50)
        print(f"Conversion complete:")
        print(f"  ✓ Success: {stats['success']}")
        print(f"  ✗ Failed:  {stats['failed']}")
        print(f"  Total:     {len(agent_files)}")
        
        return stats

def main():
    """Main conversion process."""
    source_dir = "../claude-agents"
    target_dir = "../.claude/agents"
    
    print("CDC Agent Converter")
    print("==================")
    print(f"Source: {source_dir}")
    print(f"Target: {target_dir}")
    print()
    
    converter = AgentConverter(source_dir, target_dir)
    stats = converter.convert_all()
    
    if stats['success'] > 0:
        print(f"\n✓ Successfully converted {stats['success']} agents!")
        print(f"They are now available in {target_dir}")
        print("\nTo use with Claude Code:")
        print("1. Agents are automatically discoverable")
        print("2. Use explicit invocation: 'Use the [agent-name] subagent to...'")
        print("3. Test with individual agents before batch operations")

if __name__ == "__main__":
    main()