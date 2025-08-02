# Fix 1Password Authentication in Current Project

Analyze and fix 1Password authentication for the current project to ensure it follows CDC standards and modern best practices.

## Objective

Review the current project's 1Password integration and implement the optimal authentication strategy based on available infrastructure and project requirements.

## Assessment Framework

### 1. Infrastructure Discovery

**Check for cdc-shared-config Integration**:
- Look for `../cdc-shared-config`, `./shared`, or git submodules
- Check if `cdc-shared-config/scripts/env-base.sh` exists
- Verify if `enable_1password_automation()` function is available

**Identify Current Patterns**:
- Search for existing `env.sh` files with hardcoded 1Password calls
- Find `config.yaml` files with vault/item references
- Look for direct `op read` commands in scripts
- Check for `OP_SERVICE_ACCOUNT_TOKEN` usage

### 2. Authentication Pattern Analysis

**Legacy Patterns to Identify** (require migration):
```bash
# OUTDATED - Direct op calls in env.sh
export AWS_ACCESS_KEY_ID=$(op read "op://vault/item/field")
export API_KEY=$(op read "op://vault/item/field")
```

**Modern Patterns to Implement**:
```yaml
# config.yaml - Declarative secrets management
secrets:
  aws_profiles:
    prod:
      vault: "ClientName_Production"
      item: "AWS-Production"
      region: "us-east-1"
  
  api_keys:
    openai:
      vault: "CDC_infra_admin"
      item: "OpenAI-API-Key"
      field: "credential"
```

### 3. Implementation Strategy

#### Option A: Use cdc-shared-config (When Available)

**When to Use**: Project has or can add cdc-shared-config as submodule

**Implementation Steps**:

1. **Add/Verify Submodule**:
   ```bash
   # If not present, add it
   git submodule add git@github.com:CloudDataConsulting/cdc-shared-config.git shared
   git submodule update --init --recursive
   ```

2. **Update Project env.sh**:
   ```bash
   #!/usr/bin/env bash
   # Source shared configuration base
   source "$(dirname "${BASH_SOURCE[0]}")/shared/scripts/env-base.sh"
   
   # Enable service account automation (reduces fingerprint prompts)
   enable_1password_automation
   
   # Project-specific non-secret environment variables only
   export PROJECT_NAME="$(basename "$(pwd)")"
   export PROJECT_ENV="${ENV:-development}"
   
   # Load specific credentials as needed
   load_aws_service_account      # From aws-auth.sh  
   load_dev_api_keys            # From dev-tools.sh
   ```

3. **Create/Update config.yaml**:
   ```yaml
   # Use for additional secrets not covered by shared config
   secrets:
     project_specific:
       database:
         vault: "ClientName_Production"
         item: "Database-Credentials"
   ```

#### Option B: Standalone cdc-devtools Integration

**When to Use**: Project cannot use cdc-shared-config or needs standalone solution

**Implementation Steps**:

1. **Create Modern config.yaml**:
   ```bash
   cp ~/repos/cdc/cdc-devtools/templates/config.yaml.example ./config.yaml
   ```

2. **Configure Service Account Mode**:
   ```bash
   # Enable automation mode to use service account tokens
   export CDC_1PASSWORD_MODE="automation"
   ```

3. **Update Code to Use CDCSecretsManager**:
   ```python
   from cdc_devtools.secrets import CDCSecretsManager
   
   secrets = CDCSecretsManager()
   
   # Get AWS credentials
   aws_creds = secrets.get_aws_profile_config('prod')
   s3_client = boto3.client('s3', **aws_creds)
   
   # Get API keys
   openai_key = secrets.get_api_key('openai')
   ```

### 4. Service Account Token Setup

**For Reduced Fingerprint Prompts**:

1. **Check Service Account Token Availability**:
   ```bash
   # Verify token exists in 1Password
   op read "op://CDC_infra_admin/ServiceAccountAuthToken-cdc-service-account/credential"
   ```

2. **Configure Automation Mode**:
   ```bash
   # In project env.sh or shell config
   export CDC_1PASSWORD_MODE="automation"
   ```

3. **Test Token Loading**:
   ```bash
   # Should load token without prompts
   source shared/scripts/env-base.sh
   enable_1password_automation
   echo "Token loaded: ${OP_SERVICE_ACCOUNT_TOKEN:0:20}..."
   ```

## Migration Checklist

### Phase 1: Analysis
- [ ] Check for existing cdc-shared-config integration
- [ ] Identify all current 1Password usage patterns
- [ ] Document current env.sh and config files
- [ ] Test current authentication flow

### Phase 2: Implementation
- [ ] Choose integration strategy (shared-config vs standalone)
- [ ] Create/update config.yaml with proper vault references
- [ ] Implement service account token automation
- [ ] Update code to use new authentication patterns

### Phase 3: Migration
- [ ] Replace direct `op read` calls with config-driven approach
- [ ] Remove hardcoded secrets from env.sh files
- [ ] Update scripts to use new authentication methods
- [ ] Test multi-account/multi-service workflows

### Phase 4: Cleanup
- [ ] Remove obsolete env.sh files with secrets
- [ ] Update documentation and README files
- [ ] Add config.yaml to .gitignore if it contains sensitive structure
- [ ] Verify no secrets are committed to version control

## Security Standards

### Required Practices
1. **Never commit secrets**: Only vault/item references in config.yaml
2. **Use path-based references**: `op://CDC_infra_admin/item-name/field` (not IDs)
3. **Self-documenting paths**: Avoid opaque vault/item IDs
4. **Minimal permissions**: Request only needed access levels
5. **Environment separation**: Clear dev/staging/prod boundaries

### 1Password Vault Naming Conventions
- **Client Production**: `ClientName_Production`
- **Client Development**: `ClientName_Development`  
- **CDC Infrastructure**: `CDC_infra_admin`
- **Personal/Testing**: `Personal` or `Testing`

### Item Naming Patterns
- **AWS Accounts**: `AWS-Production`, `AWS-Staging`, `AWS-Development`
- **Database Credentials**: `Database-Production`, `Snowflake-Production`
- **API Keys**: `OpenAI-API-Key`, `GitHub-Token`
- **Service Accounts**: `ServiceAccountAuthToken-cdc-service-account`

## Troubleshooting Guide

### Common Issues and Solutions

**"op: command not found"**:
```bash
brew install --cask 1password-cli
```

**"Authentication required" prompts**:
```bash
# Enable service account mode
export CDC_1PASSWORD_MODE="automation"
source shared/scripts/env-base.sh
enable_1password_automation
```

**"Config not found" errors**:
```bash
# Check config file location (searches in order):
ls -la config.yaml .cdc-project.yaml configs/config.yaml .cdc/config.yaml
```

**"Vault/item not found"**:
```bash
# Verify 1Password reference format
op read "op://VaultName/ItemName/FieldName"
# Use self-documenting names, not UUIDs
```

**Multiple fingerprint prompts**:
```bash
# Check if service account token is properly configured
echo "Service account available: ${OP_SERVICE_ACCOUNT_TOKEN:+yes}"
# Enable background loading in shared config
export CDC_1PASSWORD_BACKGROUND_LOAD="true"
```

## Validation Tests

### Verify Implementation

1. **Authentication Test**:
   ```bash
   # Should work without fingerprint prompts
   op read "op://CDC_infra_admin/test-item/password" 
   ```

2. **Multi-Account Test**:
   ```python
   secrets = CDCSecretsManager()
   prod_creds = secrets.get_aws_profile_config('prod')
   dev_creds = secrets.get_aws_profile_config('dev')
   # Should return different credentials
   ```

3. **Config Validation**:
   ```bash
   # If using cdc-devtools CLI
   cdc-secrets validate
   cdc-secrets list
   ```

## Success Criteria

- [ ] No hardcoded secrets in environment files
- [ ] Reduced or eliminated fingerprint prompts
- [ ] Multi-account workflows function correctly
- [ ] Clear separation between environments
- [ ] Audit trail through 1Password vault references
- [ ] Documentation updated to reflect new patterns
- [ ] Team can work with different credentials simultaneously

## Best Practices Reminder

1. **Test with a non-production environment first**
2. **Backup existing configuration before migration**
3. **Update team documentation after changes**
4. **Verify no secrets are exposed in git history**
5. **Use tmux window isolation for different environments**
6. **Regularly rotate service account tokens**

Use this framework to systematically assess and improve 1Password authentication in any CDC project, ensuring consistency with modern security standards and developer productivity goals.