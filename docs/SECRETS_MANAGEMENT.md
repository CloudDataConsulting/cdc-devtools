# CDC Secrets Management Strategy

## Overview

We use a config-driven approach to secrets management that avoids environment variable pollution and supports multi-account workflows. This modern approach solves the challenges of working with multiple AWS accounts, databases, and APIs simultaneously.

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

## Next Steps

1. Create your `config.yaml` from the template
2. Migrate one service at a time
3. Update documentation
4. Remove old env.sh files
5. Celebrate improved security! 🎉