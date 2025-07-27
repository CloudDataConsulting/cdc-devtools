#!/usr/bin/env bash
# CDC Standard Shell Aliases
# Common aliases for CDC development team

# ============================================================================
# Environment & Navigation
# ============================================================================
# Quick environment loading
alias e='. ./env.sh'
alias et='./env_test.sh'

# CDC workspace navigation
alias cdc='cd ${CDC_WORKSPACE:-$HOME/repos/cdc}'
alias cdcw='cd ${CDC_WORKSPACE:-$HOME/repos/cdc}'

# ============================================================================
# Git Aliases
# ============================================================================
alias g="git"
alias gs="git status"
alias gf="git fetch"
alias gfa="git fetch --all"
alias gl="git log --pretty=format:\"%h %ad %an: %s\" --date=short"
alias gg="git log --all --decorate --oneline --graph"
alias graph="git log --all --decorate --oneline --graph"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"
alias gds="git diff --staged"

# ============================================================================
# AWS Aliases
# ============================================================================
alias awssts="aws sts get-caller-identity"
alias awswho="aws sts get-caller-identity --query 'Account' --output text"
alias awsprofile='echo $AWS_PROFILE'

# ============================================================================
# Terraform Aliases
# ============================================================================
alias tf="terraform"
alias tfi="terraform init"
alias tff="terraform fmt"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfaa="terraform apply --auto-approve"
alias tfd="terraform destroy"
alias tfda="terraform destroy --auto-approve"
alias tfv="terraform validate"
alias tfw="terraform workspace"
alias tfsl="terraform state list"
alias tfss="terraform state show"
alias tfws="terraform workspace select"
alias tfwl="terraform workspace list"
alias tfwnew="terraform workspace new"
alias tfwdelete="terraform workspace delete"
alias tfwshow="terraform workspace show"

# ============================================================================
# Terragrunt Aliases (if using Terragrunt)
# ============================================================================
alias tg="terragrunt"
alias tgi="terragrunt init"
alias tgf="terragrunt fmt"
alias tgv="terragrunt validate"
alias tgp="terragrunt plan"
alias tga="terragrunt apply"
alias tgaa="terragrunt apply --auto-approve"
alias tgd="terragrunt destroy"
alias tgda="terragrunt destroy --auto-approve"

# ============================================================================
# Docker Aliases
# ============================================================================
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias di="docker images"
alias dex="docker exec -it"
alias dlog="docker logs -f"

# ============================================================================
# Python/UV Aliases
# ============================================================================
alias py="python3"
alias pip="uv pip"
alias venv="uv venv"
alias activate="source .venv/bin/activate"

# ============================================================================
# Utility Aliases
# ============================================================================
# History search
alias h="history 0 | grep"

# List files with human-readable sizes
alias ll="ls -alh"
alias la="ls -A"
alias l="ls -CF"

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Safety nets
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Create parent directories
alias mkdir="mkdir -p"

# Colorize grep output
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# ============================================================================
# CDC DevTools Aliases
# ============================================================================
alias cdc-reload="source ~/.zshrc"
alias cdc-edit-aliases="$EDITOR ${CDC_CONFIG_DIR:-~/.cdc}/aliases.sh"
alias cdc-edit-personal="$EDITOR ~/.cdc_personal"
alias cdc-edit-clients="$EDITOR ~/.cdc_clients"

# ============================================================================
# Client-Specific Aliases
# ============================================================================
# Source client-specific aliases if they exist
if [[ -f "$HOME/.cdc_clients" ]]; then
    source "$HOME/.cdc_clients"
fi

# ============================================================================
# Personal Aliases
# ============================================================================
# Source personal aliases if they exist
if [[ -f "$HOME/.cdc_personal" ]]; then
    source "$HOME/.cdc_personal"
fi