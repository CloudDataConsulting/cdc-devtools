# Convert This Project from env.sh to config.yaml Secrets Management

Please help me modernize this project's secrets management by converting from environment variable-based `env.sh` to a config-driven approach that integrates with CDC DevTools.

## 1. Analyze Current env.sh

First, examine any `env.sh`, `env_test.sh`, or similar files in this project:
- List all environment variables being set
- Identify which are secrets from 1Password
- Note any AWS profiles, database connections, or API keys
- Check for any sourcing of other env files

## 2. Create config.yaml

Based on what you find in env.sh, create a `config.yaml` file that defines which secrets this project needs. Follow this structure:

```yaml
# Project Configuration
project:
  name: "[current-project-name]"
  type: "[website|terraform|data-pipeline|etc]"
  description: "[brief description]"

# Secrets configuration - convert from env.sh
secrets:
  # If AWS credentials were in env.sh
  aws_profiles:
    default:  # or prod/dev/etc based on what env.sh had
      vault: "[1Password vault name from env.sh]"
      item: "[1Password item name from env.sh]"
      region: "[region if specified]"

  # If database connections were in env.sh
  databases:
    [db_name]:
      vault: "[vault]"
      item: "[item]"
      fields: [list fields that were being exported]

  # If API keys were in env.sh
  api_keys:
    [service_name]:
      vault: "[vault]"
      item: "[item]"
      field: "[field]"

# Non-secret configurations that were in env.sh
environment:
  # Any non-secret exports from env.sh
  [key]: "[value]"
```

## 3. Create Migration Script

Create `migrate_from_env.py` that shows how to use the new approach:

```python
#!/usr/bin/env python3
"""
Migration helper - shows how to use config.yaml instead of env.sh
This project now uses CDC DevTools secrets management.
"""
import sys
import os

# Add CDC DevTools to path if not installed
sys.path.insert(0, os.path.expanduser("~/repos/cdc-devtools"))

from secrets_management.base_secrets_manager import CDCSecretsManager

def show_migration_examples():
    """Show how to replace common env.sh patterns."""
    secrets = CDCSecretsManager()

    print("=== Migration Examples ===\n")

    # Show what secrets are available
    print("Available secrets in config.yaml:")
    # [Generate based on what was found in env.sh]

    print("\nOld way (env.sh):")
    print("  export AWS_ACCESS_KEY_ID=$(op read '...')")
    print("  boto3.client('s3')  # Uses environment")

    print("\nNew way (config.yaml):")
    print("  creds = secrets.get_aws_profile_config('default')")
    print("  boto3.client('s3', **creds)  # Explicit credentials")

if __name__ == "__main__":
    show_migration_examples()
```

## 4. Update Project Code

### For Python Projects
Replace environment variable usage:
```python
# Old
aws_key = os.environ['AWS_ACCESS_KEY_ID']

# New
from cdc_devtools.secrets import CDCSecretsManager
secrets = CDCSecretsManager()
aws_creds = secrets.get_aws_profile_config('default')
```

### For Terraform Projects
If this is a Terraform project, create a `providers_generator.py`:
```python
# Generate providers.tf with credentials from config.yaml
from cdc_devtools.secrets import CDCSecretsManager
# [Generate Terraform providers based on config.yaml]
```

### For Shell Scripts
If there are bash scripts using env.sh, show how to call Python helpers instead:
```bash
# Old: source env.sh
# New: Use Python to get specific secrets
AWS_KEY=$(python -c "from cdc_devtools.secrets import CDCSecretsManager; s=CDCSecretsManager(); print(s.get_secret('aws_access_key'))")
```

## 5. Update Documentation

Update README.md or similar:
- Remove references to `env.sh`
- Add section on config.yaml
- Reference CDC DevTools for secrets management
- Add migration notes

## 6. Clean Up

After confirming everything works:
1. Rename `env.sh` to `env.sh.backup`
2. Add `env.sh*` to .gitignore if not already there
3. Ensure config.yaml is in .gitignore (it contains secret references)
4. Create `config.yaml.example` with sanitized version for team

## 7. Test the Migration

Create a simple test script to verify secrets work:
```python
# test_secrets.py
from cdc_devtools.secrets import CDCSecretsManager

secrets = CDCSecretsManager()
# Test each secret type that was in env.sh
```

## Project-Specific Notes

Based on the project type, consider:
- **If Terraform**: How to handle backend config and provider credentials
- **If Website**: How to handle API keys and deployment credentials
- **If Snowflake**: How to handle connection strings and auth
- **If Data Pipeline**: How to handle multiple data source credentials

## Dependencies

Add to requirements.txt or similar:
```
# CDC DevTools secrets management
# Install from local path until published
-e ~/repos/cdc-devtools
```

Please analyze this project and perform the migration, focusing on maintaining all current functionality while moving to the more maintainable config.yaml approach.
