# env-config

Migrate environment-based secrets to config.yml for improved security and maintainability.

## Overview

This command helps transition projects from using env.sh files with environment variables to a more secure config.yml approach. Secrets are referenced by their 1Password vault and item names rather than stored directly.

## Instructions

### 1. Analyze Current Environment Usage

First, scan the project for environment variable usage:

```bash
# Find all env.sh files
find . -name "env.sh*" -type f | grep -v node_modules

# Search for environment variable usage in code
grep -r "os.getenv\|os.environ\|process.env\|ENV\[" . --include="*.py" --include="*.js" --include="*.ts" --include="*.go" | grep -v node_modules

# Check for existing config files
find . -name "config.yml" -o -name "config.yaml" | grep -v node_modules
```

### 2. Create or Update config.yml

Create a `config.yml` file in the project root with this structure:

```yaml
# Project Configuration
project:
  name: "project-name"
  environment: "${ENVIRONMENT:-development}"  # dev, tst, prd

# 1Password References (not actual secrets)
secrets:
  # Database credentials
  database:
    vault: "CDC_${PROJECT_NAME}_${ENVIRONMENT}"
    item: "database-${ENVIRONMENT}"
    fields:
      - host
      - port
      - username
      - password
      - database_name

  # Snowflake credentials
  snowflake:
    vault: "CDC_${PROJECT_NAME}_${ENVIRONMENT}"
    item: "snowflake-${ENVIRONMENT}.${ENGINEER_NAME}"
    fields:
      - account
      - username
      - private_key
      - private_key_passphrase
      - warehouse
      - database
      - schema
      - role

  # AWS credentials (if not using SSO)
  aws:
    vault: "CDC_infra_admin"
    item: "aws-${ENVIRONMENT}"
    fields:
      - access_key_id
      - secret_access_key
      - region

  # API keys
  api_keys:
    vault: "CDC_${PROJECT_NAME}_${ENVIRONMENT}"
    item: "api-keys-${ENVIRONMENT}"
    fields:
      - openai_api_key
      - anthropic_api_key
      - elevenlabs_api_key

# Special environment variables (exceptions)
# These MUST be set as environment variables for specific tools
required_env_vars:
  snowsql:
    - name: SNOWSQL_PRIVATE_KEY_PASSPHRASE
      source: "secrets.snowflake.private_key_passphrase"
  dbt:
    - name: DBT_PRIVATE_KEY_PASSPHRASE
      source: "secrets.snowflake.private_key_passphrase"

# Non-secret configuration
config:
  logging:
    level: "INFO"
    format: "json"

  paths:
    data: "./data"
    logs: "./ai-logs"
    temp: "./tmp"
```

### 3. Create Secret Loading Utility

Create a utility function to load secrets from 1Password based on config.yml:

**Python Example** (`utils/secrets.py`):
```python
import yaml
import subprocess
import json
import os
from typing import Dict, Any

class SecretManager:
    def __init__(self, config_path: str = "config.yml"):
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        self.secrets_cache = {}

    def get_secret(self, path: str) -> Any:
        """Get a secret value by its config path (e.g., 'database.password')"""
        if path in self.secrets_cache:
            return self.secrets_cache[path]

        # Parse the path
        parts = path.split('.')
        secret_config = self.config['secrets']

        # Navigate to the secret configuration
        for part in parts[:-1]:
            secret_config = secret_config.get(part, {})

        if not secret_config:
            raise ValueError(f"Secret configuration not found for {path}")

        # Get vault and item, substituting environment variables
        vault = os.path.expandvars(secret_config['vault'])
        item = os.path.expandvars(secret_config['item'])
        field = parts[-1]

        # Fetch from 1Password
        op_ref = f"op://{vault}/{item}/{field}"
        try:
            result = subprocess.run(
                ['op', 'read', op_ref],
                capture_output=True,
                text=True,
                check=True
            )
            value = result.stdout.strip()
            self.secrets_cache[path] = value
            return value
        except subprocess.CalledProcessError as e:
            raise ValueError(f"Failed to fetch secret {op_ref}: {e.stderr}")

    def load_required_env_vars(self):
        """Load only the required environment variables"""
        required = self.config.get('required_env_vars', {})
        for tool, vars in required.items():
            for var in vars:
                name = var['name']
                source = var['source']
                value = self.get_secret(source.replace('secrets.', ''))
                os.environ[name] = value
                print(f"Set {name} for {tool}")
```

### 4. Update Application Code

Replace environment variable usage with config.yml lookups:

**Before:**
```python
# Old approach
import os
db_password = os.getenv('DB_PASSWORD')
api_key = os.environ['OPENAI_API_KEY']
```

**After:**
```python
# New approach
from utils.secrets import SecretManager

secrets = SecretManager()
db_password = secrets.get_secret('database.password')
api_key = secrets.get_secret('api_keys.openai_api_key')

# Load required env vars for external tools
secrets.load_required_env_vars()
```

### 5. Migration Checklist

- [ ] Identify all environment variables in use
- [ ] Create config.yml with proper structure
- [ ] Map each secret to its 1Password location
- [ ] Create secret loading utility
- [ ] Update application code to use SecretManager
- [ ] Test secret retrieval with `op signin`
- [ ] Update documentation and README
- [ ] Remove old env.sh files (keep env.sh.example if needed)
- [ ] Update .gitignore to exclude config.yml if it contains sensitive structure
- [ ] Create config.yml.example for other developers

### 6. Best Practices

1. **Naming Conventions**:
   - Vaults: `CDC_${PROJECT_NAME}_${ENVIRONMENT}`
   - Items: `service-environment.username` (e.g., `snowflake-prd.bpruss`)
   - Use lowercase with hyphens for items

2. **Security**:
   - Never commit actual secrets to config.yml
   - Only store 1Password references (vault/item/field paths)
   - Use .gitignore for any local config overrides

3. **Environment Variables**:
   - Only use for tools that absolutely require them (snowsql, dbt)
   - Document all required env vars in config.yml
   - Load them programmatically when possible

4. **Developer Experience**:
   - Provide config.yml.example with structure
   - Document the required 1Password vaults/items
   - Include setup instructions in README

### 7. Example Migration

For a project using Snowflake and AWS:

1. **Old env.sh:**
```bash
export SNOWFLAKE_ACCOUNT="abc123"
export SNOWFLAKE_USER="bernie.pruss"
export SNOWFLAKE_PASSWORD=$(op read "op://CDC_myproject_prd/snowflake-prd.bpruss/password")
export AWS_ACCESS_KEY_ID=$(op read "op://CDC_infra_admin/aws-prd/access_key_id")
```

2. **New config.yml:**
```yaml
secrets:
  snowflake:
    vault: "CDC_myproject_prd"
    item: "snowflake-prd.${ENGINEER_NAME}"
    fields:
      - account
      - username
      - password
```

3. **Usage in code:**
```python
secrets = SecretManager()
snowflake_config = {
    'account': secrets.get_secret('snowflake.account'),
    'user': secrets.get_secret('snowflake.username'),
    'password': secrets.get_secret('snowflake.password')
}
```

This approach provides better security, easier secret rotation, and clearer documentation of required credentials.
