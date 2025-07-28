#!/usr/bin/env python3
"""
Audit Claude Code agents for proper formatting and content quality.
"""

import yaml
from pathlib import Path
from typing import Dict, List, Tuple

class AgentAuditor:
    """Audits Claude Code agents for quality and correctness."""
    
    def __init__(self, agents_dir: str):
        self.agents_dir = Path(agents_dir)
        self.issues = []
        
    def audit_frontmatter(self, file_path: Path, content: str) -> List[str]:
        """Audit YAML frontmatter structure."""
        issues = []
        
        if not content.startswith('---'):
            issues.append("Missing YAML frontmatter")
            return issues
            
        try:
            parts = content.split('---', 2)
            if len(parts) < 3:
                issues.append("Invalid frontmatter structure")
                return issues
                
            frontmatter = yaml.safe_load(parts[1])
            
            # Required fields
            required_fields = ['name', 'description', 'tools']
            for field in required_fields:
                if field not in frontmatter:
                    issues.append(f"Missing required field: {field}")
                elif not frontmatter[field]:
                    issues.append(f"Empty field: {field}")
                    
            # Validate name matches filename
            expected_name = file_path.stem
            if frontmatter.get('name') != expected_name:
                issues.append(f"Name mismatch: {frontmatter.get('name')} != {expected_name}")
                
        except yaml.YAMLError as e:
            issues.append(f"YAML parsing error: {e}")
            
        return issues
        
    def audit_description(self, frontmatter: dict) -> List[str]:
        """Audit description quality and trigger phrases."""
        issues = []
        description = frontmatter.get('description', '')
        
        # Check for broken text patterns
        broken_patterns = [
            'tasks involve using, setting, need to',
            'tasks involve using, evaluating',
            'tasks involve troubleshooting, facing',
            'tasks involve working, streaming',
            'tasks involve using, bridging, bridging technical',
            'tasks involve ensuring',
            'MUST BE USED for .* tasks$'  # Redundant ending
        ]
        
        for pattern in broken_patterns:
            if pattern in description:
                issues.append(f"Broken description pattern: '{pattern}'")
                
        # Check for required elements
        if 'MUST BE USED when' not in description:
            issues.append("Missing 'MUST BE USED when' trigger phrase")
            
        if not description.startswith('Expert'):
            issues.append("Description should start with 'Expert'")
            
        # Check for excessive repetition
        words = description.split()
        if len(set(words)) < len(words) * 0.7:  # 30% or more repetition
            issues.append("Excessive word repetition in description")
            
        return issues
        
    def audit_tools(self, frontmatter: dict, agent_name: str) -> List[str]:
        """Audit tool permissions appropriateness."""
        issues = []
        tools = frontmatter.get('tools', '')
        
        if isinstance(tools, str):
            tool_list = [t.strip() for t in tools.split(',')]
        else:
            tool_list = tools if isinstance(tools, list) else []
            
        # Security-sensitive agents should not have Bash
        security_agents = ['security-compliance-engineer', 'risk-specialist']
        if agent_name in security_agents and 'Bash' in tool_list:
            issues.append("Security agent should not have Bash access")
            
        # All agents should have basic tools
        basic_tools = ['Read', 'Edit', 'Glob', 'Grep']
        for tool in basic_tools:
            if tool not in tool_list:
                issues.append(f"Missing basic tool: {tool}")
                
        # Check for unnecessary tools
        if 'WebFetch' in tool_list:
            issues.append("WebFetch should be used sparingly - consider if needed")
            
        return issues
        
    def audit_agent(self, file_path: Path) -> Dict[str, any]:
        """Audit a single agent file."""
        result = {
            'file': file_path.name,
            'issues': [],
            'severity': 'ok'
        }
        
        try:
            with open(file_path, 'r') as f:
                content = f.read()
                
            # Audit frontmatter
            fm_issues = self.audit_frontmatter(file_path, content)
            result['issues'].extend(fm_issues)
            
            # Parse frontmatter for further audits
            if content.startswith('---'):
                parts = content.split('---', 2)
                if len(parts) >= 3:
                    try:
                        frontmatter = yaml.safe_load(parts[1])
                        
                        # Audit description
                        desc_issues = self.audit_description(frontmatter)
                        result['issues'].extend(desc_issues)
                        
                        # Audit tools
                        tool_issues = self.audit_tools(frontmatter, file_path.stem)
                        result['issues'].extend(tool_issues)
                        
                    except yaml.YAMLError:
                        pass  # Already caught in frontmatter audit
                        
            # Set severity
            if result['issues']:
                critical_issues = [i for i in result['issues'] if 'Broken description' in i or 'Missing required field' in i]
                if critical_issues:
                    result['severity'] = 'critical'
                elif len(result['issues']) > 5:
                    result['severity'] = 'major'
                else:
                    result['severity'] = 'minor'
                    
        except Exception as e:
            result['issues'].append(f"File reading error: {e}")
            result['severity'] = 'critical'
            
        return result
        
    def audit_all(self) -> Dict[str, any]:
        """Audit all agents and generate report."""
        results = []
        
        agent_files = list(self.agents_dir.glob('*.md'))
        
        print(f"Auditing {len(agent_files)} agents...")
        print("=" * 60)
        
        for agent_file in sorted(agent_files):
            result = self.audit_agent(agent_file)
            results.append(result)
            
            # Print immediate feedback
            if result['issues']:
                print(f"\n❌ {agent_file.name} ({result['severity']})")
                for issue in result['issues']:
                    print(f"   • {issue}")
            else:
                print(f"✅ {agent_file.name}")
                
        # Generate summary
        total = len(results)
        ok = len([r for r in results if not r['issues']])
        critical = len([r for r in results if r['severity'] == 'critical'])
        major = len([r for r in results if r['severity'] == 'major'])
        minor = len([r for r in results if r['severity'] == 'minor'])
        
        summary = {
            'total': total,
            'ok': ok,
            'critical': critical,
            'major': major,
            'minor': minor,
            'results': results
        }
        
        print("\n" + "=" * 60)
        print("AUDIT SUMMARY")
        print("=" * 60)
        print(f"Total agents: {total}")
        print(f"✅ No issues: {ok}")
        print(f"🔴 Critical:  {critical}")
        print(f"🟡 Major:     {major}")
        print(f"🟠 Minor:     {minor}")
        
        if critical > 0:
            print(f"\n🚨 {critical} agents need immediate attention!")
            
        return summary

def main():
    """Main audit process."""
    agents_dir = "../.claude/agents"
    
    print("Claude Code Agent Auditor")
    print("=" * 60)
    
    auditor = AgentAuditor(agents_dir)
    summary = auditor.audit_all()
    
    # Return exit code based on issues
    if summary['critical'] > 0:
        exit(2)  # Critical issues
    elif summary['major'] > 0:
        exit(1)  # Major issues
    else:
        exit(0)  # All good

if __name__ == "__main__":
    main()