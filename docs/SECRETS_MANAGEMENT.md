# CDC Secrets Management Strategy

## Overview

We use a config-driven approach to secrets management that avoids environment variable pollution and supports multi-account workflows. This modern approach solves the challenges of working with multiple AWS accounts, databases, and APIs simultaneously.

**Note**: This document describes the cdc-devtools approach to secrets management. For project-level environment configuration, see the [cdc-shared-config](#integration-with-cdc-shared-config) integration section below.

## Key Principles

1. **No Environment Variable Pollution**: Secrets are retrieved on-demand, not loaded into environment
2. **Explicit Configuration**: Each project declares exactly which secrets it needs
3. **Multi-Account Support**: Easy to work with multiple AWS accounts/profiles simultaneously
4. **1Password Integration**: All secrets stored in 1Password vaults
5. **Tmux Window Isolation**: Each tmux window can use different credentials

## Why This Approach?

### Problems with env.sh Files

The old pattern had significant limitations:

```bash
# Old env.sh approach - DON'T DO THIS
export AWS_ACCESS_KEY_ID=$(op read "op://Production/AWS/access_key")
export AWS_SECRET_ACCESS_KEY=$(op read "op://Production/AWS/secret_key")
export SNOWFLAKE_PASSWORD=$(op read "op://Production/Snowflake/password")
```

Problems:
- Can only have ONE AWS profile active at a time
- Switching profiles requires re-sourcing env files
- Easy to forget which environment is active
- Secrets persist in shell environment
- Risk of credential leakage

### The New Way

With config-driven secrets:
- Each tool/script explicitly declares which secrets it needs
- Multiple AWS profiles can be used simultaneously
- No environment variable conflicts
- Clear audit trail of what uses which secrets

## Migration from env.sh

### Step 1: Create config.yaml

Copy `templates/config.yaml.example` to your project root:

```bash
cp ~/repos/cdc/cdc-devtools/templates/config.yaml.example ./config.yaml
```

### Step 2: Define Your Secrets

Edit `config.yaml` to declare your project's secrets:

```yaml
secrets:
  aws_profiles:
    prod:
      vault: "MyClient_Production"
      item: "AWS-Production"
      region: "us-east-1"
```

### Step 3: Update Your Code

#### Python Example

**Old Way**:
```python
# Relies on environment variables
import boto3
s3 = boto3.client('s3')  # Uses AWS_ACCESS_KEY_ID from env
```

**New Way**:
```python
from cdc_devtools.secrets import CDCSecretsManager

secrets = CDCSecretsManager()

# Use specific AWS profile
prod_creds = secrets.get_aws_profile_config('prod')
s3 = boto3.client('s3', **prod_creds)

# Can use multiple profiles simultaneously!
terraform_creds = secrets.get_aws_profile_config('terraform_backend')
s3_terraform = boto3.client('s3', **terraform_creds)
```

#### Bash Example

**Old Way**:
```bash
source env.sh
aws s3 ls  # Uses environment variables
```

**New Way**:
```bash
# Use the CDC CLI tool
cdc-secrets exec --profile prod -- aws s3 ls

# Or in scripts
CREDS=$(cdc-secrets get aws_profiles.prod --format env)
eval "$CREDS"
aws s3 ls
```

### Step 4: Remove env.sh References

1. Delete old `env.sh` files
2. Remove `alias e='. ./env.sh'` from your shell config
3. Update any documentation that references env.sh

## Usage Examples

### Multi-Account AWS Operations

```python
from cdc_devtools.secrets import CDCSecretsManager
import boto3

secrets = CDCSecretsManager()

# Work with three different AWS accounts simultaneously
prod_creds = secrets.get_aws_profile_config('prod')
staging_creds = secrets.get_aws_profile_config('staging')
terraform_creds = secrets.get_aws_profile_config('terraform_backend')

# Create separate clients - no conflicts!
s3_prod = boto3.client('s3', **prod_creds)
s3_staging = boto3.client('s3', **staging_creds)
s3_terraform = boto3.client('s3', **terraform_creds)

# Copy from staging to prod
obj = s3_staging.get_object(Bucket='staging-data', Key='file.csv')
s3_prod.put_object(Bucket='prod-data', Key='file.csv', Body=obj['Body'].read())

# Update terraform state
s3_terraform.put_object(Bucket='terraform-state', Key='prod.tfstate', Body=state_data)
```

### Database Connections

```python
# Get Snowflake credentials
snowflake_config = secrets.get_database_config('snowflake_prod')

conn = snowflake.connector.connect(
    account=snowflake_config['account'],
    user=snowflake_config['username'],
    password=snowflake_config['password'],
    warehouse=snowflake_config['warehouse'],
    database=snowflake_config['database'],
    role=snowflake_config['role']
)
```

### API Keys

```python
# Get API keys
github_token = secrets.get_api_key('github')
openai_key = secrets.get_api_key('openai')

# Use them
headers = {'Authorization': f'token {github_token}'}
response = requests.get('https://api.github.com/user', headers=headers)
```

## Tmux Integration

### Per-Window Configurations

Each tmux window can use different credentials:

```yaml
# .cdc-project.conf
tmux_windows:
  - name: "prod-deploy"
    aws_profile: "prod"
    startup: "python deploy.py"
    
  - name: "staging-test"
    aws_profile: "staging"
    startup: "pytest tests/"
    
  - name: "terraform"
    aws_profile: "terraform_backend"
    startup: "terraform plan"
```

### Window-Specific Secrets

```python
from cdc_devtools.secrets import TmuxAwareSecretsManager

# Automatically uses the config for current tmux window
secrets = TmuxAwareSecretsManager.for_current_window()

# Each window can work with different accounts!
creds = secrets.get_aws_profile_config('default')
```

## Security Best Practices

1. **Never Commit Secrets**: Only `config.yaml` (without secrets) goes in git
2. **Use .gitignore**: Add `config.yaml` if it contains sensitive structure
3. **Minimal Permissions**: Request only the permissions you need
4. **Rotate Regularly**: Update 1Password items periodically
5. **Audit Access**: Review 1Password access logs

## Troubleshooting

### "Config not found" Error

The secrets manager looks for config files in this order:
1. `config.yaml`
2. `.cdc-project.yaml`
3. `configs/config.yaml`
4. `.cdc/config.yaml`

### "op: command not found"

Install 1Password CLI:
```bash
brew install --cask 1password-cli
```

### "Secret path not found in config"

Check your config.yaml structure. Use dot notation for nested values:
```python
# For secrets.aws_profiles.prod
secrets.get_aws_profile_config('prod')
```

### Debugging

Enable debug logging:
```python
import logging
logging.basicConfig(level=logging.DEBUG)

secrets = CDCSecretsManager()
```

## Advanced Usage

### Custom Secret Types

Extend the base manager for custom secret types:

```python
class MySecretsManager(CDCSecretsManager):
    def get_kubernetes_config(self, cluster_name: str) -> dict:
        """Get Kubernetes cluster configuration."""
        config = self._find_secret_config(f"kubernetes.{cluster_name}")
        
        return {
            'server': config['server'],
            'token': self._retrieve_from_1password(
                vault=config['vault'],
                item=config['item'],
                field='token'
            ),
            'ca_cert': self._retrieve_from_1password(
                vault=config['vault'],
                item=config['item'],
                field='ca_certificate'
            )
        }
```

### Caching Control

```python
# Clear cache when switching contexts
secrets.clear_cache()

# Or disable caching for sensitive operations
secrets._secrets_cache = None  # Disables caching
```

## CLI Tools

### Check Configuration

```bash
# List available secrets
cdc-secrets list

# Validate config file
cdc-secrets validate

# Test 1Password connection
cdc-secrets test
```

### Export for Legacy Tools

When you must use environment variables:

```bash
# Export specific profile
eval "$(cdc-secrets export --profile prod)"

# Export all secrets (use carefully!)
eval "$(cdc-secrets export --all)"
```

## Integration with cdc-shared-config

### Overview

The `cdc-shared-config` repository provides a mature, production-ready approach to project-level environment configuration that complements the cdc-devtools secrets management. When both systems are available, they work together seamlessly.

### Key Features of cdc-shared-config

Located at `../cdc-shared-config` (when used as a git submodule), it provides:

1. **`enable_1password_automation()` Function**
   - Location: `cdc-shared-config/scripts/env-base.sh`
   - Purpose: Automatically configures 1Password service account tokens
   - Reduces fingerprint prompts through token caching
   - Supports both interactive and automation modes

2. **Service Account Management**
   ```bash
   # In cdc-shared-config/scripts/env-base.sh
   enable_1password_automation() {
       if [[ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
           return 0  # Already loaded
       fi
       
       if [[ "${CDC_1PASSWORD_MODE:-interactive}" == "automation" ]]; then
           load_1password_service_account
       fi
   }
   
   load_1password_service_account() {
       local token_path="op://CDC_infra_admin/ServiceAccountAuthToken-cdc-service-account/credential"
       export OP_SERVICE_ACCOUNT_TOKEN="$(op read "$token_path" 2>/dev/null || true)"
   }
   ```

3. **Lazy Loading Pattern**
   - Credentials are only loaded when explicitly needed
   - Reduces shell startup time
   - Minimizes authentication prompts

### How to Use cdc-shared-config with cdc-devtools

#### 1. Add as a Git Submodule

```bash
# In your project root
git submodule add git@github.com:CloudDataConsulting/cdc-shared-config.git shared
git submodule update --init --recursive
```

#### 2. Source in Your Project's env.sh

```bash
#!/usr/bin/env bash
# Source the shared configuration
source "$(dirname "${BASH_SOURCE[0]}")/shared/scripts/env-base.sh"

# Your project-specific configuration
export PROJECT_NAME="my-project"
export PROJECT_ENV="development"

# Enable 1Password automation for reduced prompts
enable_1password_automation

# Load specific credentials as needed
load_aws_service_account      # From aws-auth.sh
load_snowflake_credentials "terraform"  # From snowflake-auth.sh
load_dev_api_keys            # From dev-tools.sh
```

#### 3. Integration with cdc-devtools

When both systems are present, cdc-devtools will:

1. **Detect cdc-shared-config**:
   ```python
   # In CDCSecretsManager
   def __init__(self):
       self._check_shared_config_integration()
   
   def _check_shared_config_integration(self):
       """Check if cdc-shared-config is available."""
       shared_config_paths = [
           os.environ.get('CDC_SHARED_CONFIG_PATH', ''),
           '../cdc-shared-config',
           '../../cdc-shared-config'
       ]
       
       for path in shared_config_paths:
           if os.path.exists(os.path.join(path, 'scripts/env-base.sh')):
               self.shared_config_path = path
               break
   ```

2. **Leverage Service Account Tokens**:
   ```python
   # Automatically use OP_SERVICE_ACCOUNT_TOKEN if available
   if 'OP_SERVICE_ACCOUNT_TOKEN' in os.environ:
       # Use service account for 1Password operations
       self._use_service_account = True
   ```

### Key Differences

| Aspect | cdc-devtools Secrets | cdc-shared-config |
|--------|---------------------|-------------------|
| **Scope** | Developer productivity, multi-account | Project environment setup |
| **Loading** | On-demand, config-driven | Environment variables |
| **Context** | Tmux window-aware | Project-wide |
| **Use Case** | Development workflows | Project standardization |

### Best Practices for Integration

1. **Use cdc-shared-config for**:
   - Project-wide environment variables
   - Standardized authentication patterns
   - CI/CD environment setup
   - Team-shared configurations

2. **Use cdc-devtools secrets for**:
   - Multi-account development workflows
   - Tmux window-specific credentials
   - On-demand secret retrieval
   - Developer productivity enhancements

3. **Reducing Authentication Prompts**:
   ```bash
   # In your shell initialization (e.g., ~/.zshrc)
   # Enable 1Password automation globally
   export CDC_1PASSWORD_MODE="automation"
   
   # Or in project env.sh
   source shared/scripts/env-base.sh
   enable_1password_automation
   ```

4. **Service Account Setup**:
   - Store service account token in 1Password: `CDC_infra_admin/ServiceAccountAuthToken-cdc-service-account`
   - Export token for Terraform: `export TF_VAR_op_service_account_token="${OP_SERVICE_ACCOUNT_TOKEN}"`
   - Use for non-interactive scenarios (CI/CD, automation)

### Migration Path

If you're currently using only cdc-devtools or only cdc-shared-config:

1. **Start with cdc-shared-config** as your foundation for project setup
2. **Layer cdc-devtools** on top for enhanced developer experience
3. **Gradually migrate** credentials to the appropriate system based on use case

### Example: Full Integration

```yaml
# config.yaml (cdc-devtools)
secrets:
  integration:
    use_shared_config: true
    shared_config_path: "./shared"
    
  # Override or extend shared config
  aws_profiles:
    development:
      # Uses cdc-shared-config for base credentials
      # Adds tmux-specific context
      inherit_from: "shared_config"
      tmux_window_override: true
```

```bash
# Project env.sh
#!/usr/bin/env bash

# Source shared config for base functionality
source "./shared/scripts/env-base.sh"

# Enable automation to reduce prompts
enable_1password_automation

# Load project credentials
load_aws_service_account "development"

# cdc-devtools will layer additional functionality on top
```

## Next Steps

1. Create your `config.yaml` from the template
2. Add cdc-shared-config as a submodule if working on a CDC project
3. Migrate one service at a time
4. Update documentation
5. Remove old env.sh files
6. Celebrate improved security! 🎉