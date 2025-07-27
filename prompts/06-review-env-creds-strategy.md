# Implement Modern Secrets Management Strategy for CDC DevTools

## Background: Evolution of Our Secrets Management

We've learned important lessons about secrets management and need to implement a better pattern in CDC DevTools.

### Old Pattern (What We're Moving Away From)
We used `env.sh` files that:
- Loaded ALL secrets into environment variables
- Called 1Password to populate these variables
- Required sourcing before work could begin

### Problems We Encountered
1. **Multi-Account Complexity**: Projects often need multiple AWS profiles:
   - `aws-prod`: Target production environment
   - `aws-terraform`: Backend state storage account
   - `aws-data`: Third account for data sources

2. **Environment Variable Conflicts**: Switching between profiles required complex env var juggling

3. **Cognitive Overload**: Developers had to remember which environment was currently loaded

## New Strategy: Config-Driven Secrets

Implement a `config.yaml` approach where:
- Each project has a `config.yaml` (or `.cdc-project.yaml`)
- Config specifies WHICH secrets are needed
- Secrets are pulled from 1Password ON-DEMAND
- No environment variable pollution

## Implementation Tasks

### 1. Create Secrets Management Framework

Create `secrets-management/base_secrets_manager.py`:

```python
"""
CDC Secrets Management - Pull secrets on demand from 1Password
"""
import yaml
import subprocess
from typing import Dict, Any, Optional
from pathlib import Path


class CDCSecretsManager:
    """Manage secrets retrieval from 1Password based on config."""

    def __init__(self, config_path: str = "config.yaml"):
        self.config_path = Path(config_path)
        self.config = self._load_config()
        self._secrets_cache = {}

    def _load_config(self) -> Dict[str, Any]:
        """Load project configuration."""
        if not self.config_path.exists():
            raise FileNotFoundError(f"Config not found: {self.config_path}")

        with open(self.config_path) as f:
            return yaml.safe_load(f)

    def get_secret(self, secret_name: str, vault: Optional[str] = None) -> str:
        """
        Retrieve a secret from 1Password.

        Example config.yaml:
        secrets:
          aws_profiles:
            prod:
              vault: "CDC_Production"
              item: "AWS-Production"
              field: "access_key"
            terraform_backend:
              vault: "CDC_Infrastructure"
              item: "AWS-Terraform-Backend"
              field: "access_key"
        """
        # Check cache first
        cache_key = f"{vault}:{secret_name}"
        if cache_key in self._secrets_cache:
            return self._secrets_cache[cache_key]

        # Get from config
        secret_config = self._find_secret_config(secret_name)

        # Retrieve from 1Password
        secret_value = self._retrieve_from_1password(
            vault=secret_config.get('vault', vault),
            item=secret_config['item'],
            field=secret_config.get('field', 'password')
        )

        # Cache it
        self._secrets_cache[cache_key] = secret_value
        return secret_value

    def get_aws_profile_config(self, profile_name: str) -> Dict[str, str]:
        """Get AWS credentials for a specific profile."""
        profile_config = self.config['secrets']['aws_profiles'][profile_name]

        return {
            'access_key': self.get_secret(f"aws_profiles.{profile_name}.access_key"),
            'secret_key': self.get_secret(f"aws_profiles.{profile_name}.secret_key"),
            'region': profile_config.get('region', 'us-east-1'),
            'role_arn': profile_config.get('role_arn')
        }
```

### 2. Create Example Config Template

Create `templates/config.yaml.example`:

```yaml
# CDC Project Configuration
project:
  name: "my-client-project"
  type: "data-pipeline"
  client: "ClientName"

# Secrets configuration - defines what secrets this project needs
secrets:
  # AWS Profiles - No environment variables, pulled on demand
  aws_profiles:
    prod:
      vault: "ClientName_Production"
      item: "AWS-Production-Access"
      region: "us-east-1"

    terraform_backend:
      vault: "CDC_Infrastructure"
      item: "Terraform-State-Backend"
      region: "us-east-1"

    data_source:
      vault: "ClientName_DataLake"
      item: "AWS-DataLake-ReadOnly"
      region: "us-west-2"

  # Database connections
  databases:
    snowflake_prod:
      vault: "ClientName_Production"
      item: "Snowflake-Production"
      fields:
        - account
        - username
        - password
        - warehouse

  # API Keys
  api_keys:
    github:
      vault: "CDC_Development"
      item: "GitHub-API-Token"
      field: "token"

# Tool configurations (non-secret)
tools:
  terraform:
    version: "1.5.0"
    backend_profile: "terraform_backend"  # References aws_profiles above

  dbt:
    version: "1.7.0"
    target_database: "snowflake_prod"  # References databases above
```

### 3. Create Migration Guide

Create `docs/SECRETS_MANAGEMENT.md`:

```markdown
# CDC Secrets Management Strategy

## Overview

We use a config-driven approach to secrets management that avoids environment variable pollution and supports multi-account workflows.

## Key Principles

1. **No Environment Variable Pollution**: Secrets are retrieved on-demand, not loaded into environment
2. **Explicit Configuration**: Each project declares exactly which secrets it needs
3. **Multi-Account Support**: Easy to work with multiple AWS accounts/profiles simultaneously
4. **1Password Integration**: All secrets stored in 1Password vaults

## Migration from env.sh

### Old Way (Don't Do This)
```bash
# env.sh
export AWS_ACCESS_KEY_ID=$(op read "op://Production/AWS/access_key")
export AWS_SECRET_ACCESS_KEY=$(op read "op://Production/AWS/secret_key")
source env.sh  # Pollutes environment
```

### New Way (Do This)
```python
from cdc_devtools.secrets import CDCSecretsManager

secrets = CDCSecretsManager()

# Use different AWS profiles without environment conflicts
prod_creds = secrets.get_aws_profile_config('prod')
terraform_creds = secrets.get_aws_profile_config('terraform_backend')

# Use them directly in code
prod_client = boto3.client(
    's3',
    aws_access_key_id=prod_creds['access_key'],
    aws_secret_access_key=prod_creds['secret_key']
)
```

## Setting Up a New Project

1. Copy `config.yaml.example` to your project
2. Define the secrets your project needs
3. Use CDCSecretsManager in your code
4. Never commit actual secrets!
```

### 4. Create Python Integration Examples

Create `secrets-management/examples/`:

#### multi_aws_example.py
```python
"""Example: Working with multiple AWS accounts simultaneously."""

from cdc_devtools.secrets import CDCSecretsManager
import boto3

secrets = CDCSecretsManager()

# Get credentials for different accounts
prod_creds = secrets.get_aws_profile_config('prod')
terraform_creds = secrets.get_aws_profile_config('terraform_backend')
data_creds = secrets.get_aws_profile_config('data_source')

# Create separate clients - no environment variable conflicts!
s3_prod = boto3.client('s3', **prod_creds)
s3_terraform = boto3.client('s3', **terraform_creds)
s3_data = boto3.client('s3', **data_creds)

# Work with all three simultaneously
prod_buckets = s3_prod.list_buckets()
state_files = s3_terraform.list_objects(Bucket='terraform-state')
data_files = s3_data.list_objects(Bucket='data-lake')
```

### 5. Create Terraform Integration

Create `secrets-management/terraform_helper.py`:

```python
"""Helper for Terraform with multiple AWS profiles."""

class TerraformSecretsHelper:
    def __init__(self, secrets_manager):
        self.secrets = secrets_manager

    def setup_providers_file(self):
        """Generate Terraform providers with correct credentials."""
        template = '''
provider "aws" {
  alias = "{alias}"
  region = "{region}"
  access_key = "{access_key}"
  secret_key = "{secret_key}"
}
'''

        providers = []
        for profile_name in self.secrets.config['secrets']['aws_profiles']:
            creds = self.secrets.get_aws_profile_config(profile_name)
            providers.append(template.format(
                alias=profile_name,
                **creds
            ))

        return '\n'.join(providers)
```

### 6. Update Developer Config Installation

Add to `developer-config/install.sh`:

```bash
# Check for old env.sh pattern
if find ~ -name "env.sh" -type f 2>/dev/null | grep -q .; then
    echo "⚠️  Found env.sh files - these should be migrated to config.yaml"
    echo "See docs/SECRETS_MANAGEMENT.md for migration guide"
fi
```

### 7. Remove/Update Environment Variable Code

- Look for any `env.sh` references in imported code
- Update to use the new CDCSecretsManager pattern
- Remove the `alias e='. ./env.sh'` from shell configs
- Add deprecation notice if env.sh files are found

## Summary

This new approach solves the multi-account problem by:
1. Eliminating environment variable conflicts
2. Making it explicit which secrets each tool/script uses
3. Supporting simultaneous multi-account operations
4. Keeping secrets out of the shell environment

The config.yaml becomes the single source of truth for what secrets a project needs, while keeping the actual secret values in 1Password.
