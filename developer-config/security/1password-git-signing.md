# Git Commit Signing with 1Password

Secure your Git commits using 1Password's SSH key management for cryptographic signing.

## Why Sign Commits?

- **Verification**: Proves commits actually came from you
- **Security**: Prevents impersonation
- **Compliance**: Required by many organizations
- **Trust**: Shows professionalism in open source

## Prerequisites

- 1Password 8 or later
- 1Password CLI installed
- Git 2.34.0 or later

## Setup Instructions

### 1. Install 1Password CLI

```bash
# macOS with Homebrew
brew install --cask 1password-cli

# Verify installation
op --version
```

### 2. Generate or Import SSH Key in 1Password

1. Open 1Password
2. Create new item → SSH Key
3. Generate new key or import existing
4. Name it clearly (e.g., "Git Signing Key - Work")

### 3. Configure Git for SSH Signing

```bash
# Set GPG format to SSH
git config --global gpg.format ssh

# Point to 1Password's signing program
git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

# Get your public key from 1Password and set as signing key
# Copy the public key from 1Password, then:
git config --global user.signingkey "ssh-rsa AAAAB3NzaC1yc2E..."
```

### 4. Enable Commit Signing

```bash
# Sign all commits by default
git config --global commit.gpgsign true

# Or sign individual commits with -S
git commit -S -m "Signed commit"
```

### 5. Configure GitHub/GitLab

#### GitHub
1. Go to Settings → SSH and GPG keys
2. Click "New SSH key"
3. Select "Signing Key" as key type
4. Paste your public key from 1Password

#### GitLab
1. Go to Preferences → SSH Keys
2. Add your public key
3. Select "Authentication and Signing"

## Verification

### Test Signing

```bash
# Create a test commit
git commit --allow-empty -m "Test signed commit"

# Verify the signature
git log --show-signature -1
```

### View Signature Details

```bash
# See signature in log
git log --pretty="format:%h %G? %aN  %s" -10

# Legend:
# G = Good signature
# B = Bad signature
# U = Good signature, unknown validity
# X = Good signature, expired
# Y = Good signature, expired key
# R = Good signature, revoked key
# E = Missing key
# N = No signature
```

## Troubleshooting

### "Error: Unable to sign commit"

1. Ensure 1Password is running and unlocked
2. Check CLI integration is enabled in 1Password settings
3. Verify the signing key exists in 1Password

### "Signing key not found"

```bash
# List available keys
op item list --categories "SSH Key"

# Ensure your key ID matches
git config --global user.signingkey "$(op item get 'Git Signing Key' --fields 'public key')"
```

### Test 1Password CLI

```bash
# Authenticate
eval $(op signin)

# Test signing
echo "test" | op-ssh-sign -Y sign -n git -f ~/.ssh/id_rsa
```

## Team Recommendations

1. **Standardize key names**: Use consistent naming like "CDC Git Signing - [Your Name]"
2. **Document key fingerprints**: Keep a record of team member key fingerprints
3. **Regular key rotation**: Rotate keys annually or per security policy
4. **Backup keys**: Ensure keys are backed up in 1Password vault

## Advanced Configuration

### Per-Repository Signing

```bash
# Enable for specific repo only
cd /path/to/important/repo
git config commit.gpgsign true
```

### Conditional Signing

```bash
# Only sign commits to main/master
git config --global branch.main.signcommits true
git config --global branch.master.signcommits true
```

### Verification Aliases

Add to your git config:

```gitconfig
[alias]
    # Show signatures in log
    slog = log --show-signature
    
    # List signed commits
    signed = log --pretty="format:%h %G? %aN  %s" --grep="^G"
    
    # List unsigned commits
    unsigned = log --pretty="format:%h %G? %aN  %s" --grep="^N"
```

## Security Best Practices

1. **Never share private keys**
2. **Use strong passphrases** in 1Password
3. **Enable 2FA** on 1Password account
4. **Audit key usage** regularly
5. **Revoke compromised keys** immediately

## Resources

- [Git Documentation on Signing](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
- [1Password SSH Documentation](https://developer.1password.com/docs/ssh/)
- [GitHub Commit Signature Verification](https://docs.github.com/en/authentication/managing-commit-signature-verification)