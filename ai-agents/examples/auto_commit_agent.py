"""Example agent with automatic git commits."""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../..'))

from ai_agents.base_agents.git_aware_agent import GitAwareAgent
from ai_agents.base_agents.model_aware_agent import ModelAwareAgent


class AutoCommitAgent(GitAwareAgent, ModelAwareAgent):
    """Agent that combines model routing with auto-commits."""

    def __init__(self):
        GitAwareAgent.__init__(self, "auto-commit-agent")
        ModelAwareAgent.__init__(self, "auto-commit-agent")

    def process_feature(self, feature_request):
        """Process a feature request with automatic commits."""

        # Create feature branch
        branch = self.git.ensure_branch(f"ai/feature/{feature_request['name']}")
        print(f"Created branch: {branch}")

        # Design phase
        print(f"\n1. Design Phase for {feature_request['name']}")
        design = self.execute_with_model(
            task_type="system_design",
            description=f"Design {feature_request['name']}",
            task_fn=lambda model: self._create_design(feature_request, model)
        )
        self.complete_task("Design Complete", f"Created design for {feature_request['name']}")

        # Implementation phase
        print("\n2. Implementation Phase")
        for component in design['components']:
            code = self._implement_component(component)
            self.git.track_file_change(f"src/{component['name']}.py", "created")

        self.complete_task("Implementation Complete", "All components implemented")

        # Testing phase
        print("\n3. Testing Phase")
        tests = self._create_tests(design)
        for test_file in tests:
            self.git.track_file_change(test_file, "created")

        self.complete_task("Tests Added", "Test suite complete")

        # Final push
        self.git.push_changes()

        return {
            "branch": branch,
            "commits": 3,  # Design, Implementation, Tests
            "status": "complete"
        }

    def _create_design(self, feature_request, model):
        """Create design using selected model."""
        print(f"  Creating design with {model}")
        # Simulate design creation
        return {
            "components": [
                {"name": "feature_core", "type": "module"},
                {"name": "feature_api", "type": "api"},
                {"name": "feature_utils", "type": "utils"}
            ]
        }

    def _implement_component(self, component):
        """Implement a component."""
        print(f"  Implementing {component['name']}")
        # Simulate implementation
        return f"# Implementation of {component['name']}\n\nclass {component['name'].title()}:\n    pass"

    def _create_tests(self, design):
        """Create tests for the design."""
        test_files = []
        for component in design['components']:
            test_file = f"tests/test_{component['name']}.py"
            print(f"  Creating test: {test_file}")
            test_files.append(test_file)
        return test_files


# Example usage
if __name__ == "__main__":
    print("=== AutoCommitAgent Example ===\n")
    print("This example demonstrates automatic git commits during AI work.\n")
    
    agent = AutoCommitAgent()
    
    # Example feature request
    feature_request = {
        "name": "user-authentication",
        "description": "Add user authentication system",
        "requirements": ["login", "logout", "session management"]
    }
    
    print(f"Processing feature: {feature_request['name']}")
    print("-" * 50)
    
    # Note: This would actually create branches and commits if run in a git repo
    # For safety, we're just demonstrating the flow
    try:
        # Comment out the actual processing to avoid creating branches
        # result = agent.process_feature(feature_request)
        # print(f"\nResult: {result}")
        
        print("\nNOTE: Actual git operations are commented out for safety.")
        print("In production, this would:")
        print("1. Create a feature branch")
        print("2. Commit after design phase")
        print("3. Commit after implementation")
        print("4. Commit after tests")
        print("5. Push all commits to remote")
        
    except Exception as e:
        print(f"Error: {e}")
        print("Make sure you're in a git repository to use git features.")