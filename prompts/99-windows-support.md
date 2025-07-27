# Add Windows WSL Documentation to CDC DevTools

Please add Windows setup documentation to help Windows team members use CDC DevTools.

## 1. Create Windows Setup Guide

Create `docs/WINDOWS_SETUP.md`:

```markdown
# Windows Setup Guide for CDC DevTools

CDC DevTools uses tmux and shell scripts that require a Unix-like environment. Windows users should use WSL2 (Windows Subsystem for Linux) for the best experience.

## Prerequisites

- Windows 10 version 2004+ or Windows 11
- Administrator access (for initial WSL installation)

## Setup Instructions

### 1. Install WSL2

Open PowerShell as Administrator and run:

```powershell
# Install WSL with Ubuntu (default)
wsl --install

# Restart your computer when prompted
```

### 2. Set up Windows Terminal (Recommended)

Install Windows Terminal from the Microsoft Store for the best terminal experience.

### 3. Clone and Set Up CDC DevTools

Open Windows Terminal and start a WSL session:

```bash
# Enter WSL
wsl

# Navigate to your Windows filesystem
cd /mnt/c/Users/YOUR_USERNAME

# Create development directory
mkdir -p repos
cd repos

# Clone CDC DevTools
git clone https://github.com/CloudDataConsulting/cdc-devtools.git
cd cdc-devtools

# Run the setup
./team-setup/onboard_developer.sh
```

### 4. Daily Usage

Always run CDC DevTools commands from within WSL:

```bash
# Start WSL
wsl

# Navigate to your project
cd /mnt/c/Users/YOUR_USERNAME/repos/your-project

# Use CDC tools normally
cdc-create-session "my-project"
cdc-monitor
```

## Tips for Windows Users

### File Access
- Your Windows files are available at `/mnt/c/`
- Your WSL home directory is separate from Windows home
- Recommend keeping repos in `/mnt/c/Users/YOUR_USERNAME/repos/` for easy access from both Windows and WSL

### VS Code Integration
VS Code works seamlessly with WSL:
1. Install the "WSL" extension in VS Code
2. Open any WSL folder with `code .` from WSL terminal
3. Terminal in VS Code will automatically use WSL

### Performance Tips
- Keep repositories on the Windows filesystem (`/mnt/c/`) if you need Windows tools access
- For best performance, keep them in the WSL filesystem (`~/repos/`)

## Troubleshooting

### "Command not found" errors
Make sure you're running commands from within WSL, not PowerShell or CMD.

### Tmux not working
Tmux only works inside WSL. Ensure you're in a WSL session.

### Permission issues
If you get permission errors, check file ownership:
```bash
# Fix permissions if needed
chmod +x script_name.sh
```

## Need Help?

- WSL Documentation: https://docs.microsoft.com/en-us/windows/wsl/
- Ask in the CDC DevTools Slack channel
```

## 2. Update Main README.md

Add this section to the main README.md after the installation section:

```markdown
### Platform Support

CDC DevTools is designed for Unix-like environments (macOS and Linux).

**Windows Users**: Please see [Windows Setup Guide](docs/WINDOWS_SETUP.md) for WSL2 instructions.
```

## 3. Update Team Onboarding Script

Add Windows detection to `team-setup/onboard_developer.sh`:

```bash
# Add near the top of the script, after the welcome message

# Detect if running on Windows without WSL
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "⚠️  Windows detected without WSL!"
    echo "Please follow the Windows setup guide:"
    echo "  docs/WINDOWS_SETUP.md"
    echo ""
    echo "CDC DevTools requires WSL2 for tmux support."
    exit 1
fi

# Detect if running in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "✅ WSL detected - good to go!"
    echo ""
fi
```

## 4. Create Quick Start Script for Windows

Create `windows-quick-start.ps1` in the root directory:

```powershell
# CDC DevTools Windows Quick Start
# This script helps Windows users get started with WSL

Write-Host "CDC DevTools Windows Setup" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if WSL is installed
$wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue

if (-not $wslInstalled) {
    Write-Host "WSL is not installed. Installing now..." -ForegroundColor Yellow
    Write-Host "You will need to restart after installation." -ForegroundColor Yellow

    # Check if running as admin
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "Please run this script as Administrator to install WSL" -ForegroundColor Red
        exit 1
    }

    wsl --install
    Write-Host ""
    Write-Host "✅ WSL installed! Please restart your computer and run this script again." -ForegroundColor Green
    exit 0
}

Write-Host "✅ WSL is installed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open Windows Terminal or run 'wsl' in PowerShell"
Write-Host "2. Follow the setup instructions in docs/WINDOWS_SETUP.md"
Write-Host ""
Write-Host "Quick command to get started:" -ForegroundColor Green
Write-Host "  wsl -e bash -c 'cd /mnt/c/Users/$env:USERNAME && cat repos/cdc-devtools/docs/WINDOWS_SETUP.md'"
```

## 5. Add Windows-Specific Gitignore

Update `.gitignore` to include Windows-specific files:

```
# Windows specific
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/
*.lnk

# WSL
.bash_history
.sudo_as_admin_successful
```

This documentation will help Windows team members get up and running quickly with WSL2 while keeping the setup simple and maintainable!
