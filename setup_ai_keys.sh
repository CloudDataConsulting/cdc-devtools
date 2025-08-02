#!/bin/bash
# Script to add AI API key loading function to zshrc-additions

ADDITIONS_FILE="$HOME/.bpruss-config/shell/zshrc-additions"

# Check if the function already exists
if grep -q "load_ai_api_keys" "$ADDITIONS_FILE"; then
    echo "❌ load_ai_api_keys function already exists in $ADDITIONS_FILE"
    exit 1
fi

# Add the new function after the aubpbi alias (line 133)
cat >> "$ADDITIONS_FILE" << 'EOF'

# Load AI Service API Keys
load_ai_api_keys() {
    echo "🤖 Loading AI API keys..."
    
    # Check if AI_ENGINEER is set
    if [ -z "$AI_ENGINEER" ]; then
        echo "⚠️  AI_ENGINEER not set. Please set it to your name (e.g., 'bpruss')"
        return 1
    fi
    
    # Only load if not already set (to avoid repeated 1Password calls)
    if [ -z "$OPENAI_API_KEY" ]; then
        export OPENAI_API_KEY="$(op read "op://CDC_infra_admin/API-Cred-openai-$AI_ENGINEER/credential" 2>/dev/null || echo '')"
        [ -n "$OPENAI_API_KEY" ] && echo "✅ OpenAI API key loaded" || echo "⚠️  OpenAI API key not found in 1Password"
    else
        echo "✅ OpenAI API key already loaded"
    fi
    
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        export ANTHROPIC_API_KEY="$(op read "op://CDC_infra_admin/API-Cred-Anthropic-$AI_ENGINEER/credential" 2>/dev/null || echo '')"
        [ -n "$ANTHROPIC_API_KEY" ] && echo "✅ Anthropic API key loaded" || echo "⚠️  Anthropic API key not found in 1Password"
    else
        echo "✅ Anthropic API key already loaded"
    fi
    
    # ElevenLabs might be in Personal vault or CDC vault - try both
    if [ -z "$ELEVENLABS_API_KEY" ]; then
        # Try CDC vault first
        export ELEVENLABS_API_KEY="$(op read "op://CDC_infra_admin/API-Cred-ElevenLabs-$AI_ENGINEER/credential" 2>/dev/null || echo '')"
        
        # If not found in CDC vault, try Personal vault
        if [ -z "$ELEVENLABS_API_KEY" ]; then
            export ELEVENLABS_API_KEY="$(op read "op://Personal/ElevenLabs/api_key" 2>/dev/null || echo '')"
        fi
        
        [ -n "$ELEVENLABS_API_KEY" ] && echo "✅ ElevenLabs API key loaded" || echo "⚠️  ElevenLabs API key not found in 1Password"
    else
        echo "✅ ElevenLabs API key already loaded"
    fi
    
    # Also load YouTube and Gemini if you use them
    if [ -z "$YOUTUBE_API_KEY" ]; then
        export YOUTUBE_API_KEY="$(op read "op://CDC_infra_admin/API-Cred-Google-Youtube-data-$AI_ENGINEER/credential" 2>/dev/null || echo '')"
        [ -n "$YOUTUBE_API_KEY" ] && echo "✅ YouTube API key loaded" || echo "⚠️  YouTube API key not found"
    fi
    
    if [ -z "$GEMINI_API_KEY" ]; then
        export GEMINI_API_KEY="$(op read "op://CDC_infra_admin/API-Cred-google-aistudio-$AI_ENGINEER/credential" 2>/dev/null || echo '')"
        [ -n "$GEMINI_API_KEY" ] && echo "✅ Gemini API key loaded" || echo "⚠️  Gemini API key not found"
    fi
}
alias aikeys="load_ai_api_keys"

# Auto-load AI keys if we have a cached 1Password session
# This runs silently in the background to avoid delays
if command -v op >/dev/null 2>&1 && op account list >/dev/null 2>&1; then
    (load_ai_api_keys >/dev/null 2>&1 &)
fi
EOF

echo "✅ Added load_ai_api_keys function to $ADDITIONS_FILE"
echo ""
echo "To use it:"
echo "1. Reload your shell: source ~/.zshrc"
echo "2. Run: aikeys"
echo ""
echo "The function will load API keys from 1Password using the pattern:"
echo "   op://CDC_infra_admin/API-Cred-<service>-$AI_ENGINEER/credential"
echo ""
echo "Your AI_ENGINEER is set to: ${AI_ENGINEER:-not set}"