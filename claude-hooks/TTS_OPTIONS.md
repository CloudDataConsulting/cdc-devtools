# Text-to-Speech Options for Claude Hooks

## Current TTS Priority Order

The hooks check for TTS engines in this order:
1. **ElevenLabs** (if `ELEVENLABS_API_KEY` is set)
2. **OpenAI** (if `OPENAI_API_KEY` is set)
3. **pyttsx3** (fallback - no API key required)

## Option 1: ElevenLabs (Premium Quality)

### Features
- **Model**: Turbo v2.5 - Optimized for real-time use
- **Voice**: Currently uses `WejK3H1m7MI9CHnIjW9K` voice ID
- **Quality**: Professional studio-quality voices
- **Speed**: Fast generation with low latency
- **Format**: MP3 44.1kHz 128kbps

### Setup
1. Get API key from [ElevenLabs](https://elevenlabs.io)
2. Add to your `.env` file:
   ```bash
   ELEVENLABS_API_KEY=your_api_key_here
   ```

### Available Voices
To explore different voices, visit [ElevenLabs Voice Library](https://elevenlabs.io/voice-library)

You can change the voice by editing the `voice_id` in `elevenlabs_tts.py`:
```python
voice_id="WejK3H1m7MI9CHnIjW9K",  # Change this to any voice ID
```

Popular voice IDs:
- `21m00Tcm4TlvDq8ikWAM` - Rachel (calm, conversational)
- `AZnzlk1XvdvUeBnXmlld` - Domi (young, energetic)
- `EXAVITQu4vr4xnSDxMaL` - Bella (soft, friendly)
- `ErXwobaYiN019PkySvjV` - Antoni (professional, clear)
- `MF3mGyEYCl7XYWbV9V6O` - Elli (expressive, warm)

### Test Different Voices
```bash
# Test with current voice
./claude-hooks/utils/tts/elevenlabs_tts.py "Hello from ElevenLabs!"

# To test different voices, edit the voice_id in the script first
```

## Option 2: OpenAI TTS (High Quality)

### Features
- **Model**: gpt-4o-mini-tts (latest model)
- **Voice**: Nova (engaging and warm)
- **Instructions**: Can provide speaking style instructions
- **Quality**: Natural, human-like speech
- **Streaming**: Live audio streaming

### Setup
1. Get API key from [OpenAI Platform](https://platform.openai.com)
2. Add to your `.env` file:
   ```bash
   OPENAI_API_KEY=your_api_key_here
   ```

### Available Voices
OpenAI TTS offers these voices:
- `nova` - Warm and engaging (current)
- `alloy` - Neutral and balanced
- `echo` - Smooth and confident
- `fable` - Expressive and dramatic
- `onyx` - Deep and authoritative
- `shimmer` - Soft and pleasant

To change voice, edit `openai_tts.py`:
```python
voice="nova",  # Change to any voice above
```

### Test Different Voices
```bash
# Test with current voice
./claude-hooks/utils/tts/openai_tts.py "Hello from OpenAI!"
```

## Option 3: pyttsx3 (Offline Fallback)

### Features
- **Offline**: No internet or API required
- **Free**: No costs
- **Cross-platform**: Works on Mac, Windows, Linux
- **Configurable**: Rate and volume adjustable

### Current Settings
```python
engine.setProperty('rate', 180)    # Words per minute
engine.setProperty('volume', 0.8)  # 0.0 to 1.0
```

### Available Voices (macOS)
On macOS, pyttsx3 uses system voices. To see available voices:
```bash
# List all system voices
say -v "?"
```

To use a specific voice, add to `pyttsx3_tts.py`:
```python
voices = engine.getProperty('voices')
# Use a specific voice (e.g., index 0, 1, 2...)
engine.setProperty('voice', voices[0].id)
```

Popular macOS voices:
- Samantha (default female)
- Alex (male)
- Victoria (British female)
- Daniel (British male)

## Quick Voice Comparison

Test all three engines:
```bash
# Test pyttsx3 (current)
./claude-hooks/test_tts.py custom "Testing pyttsx3 voice"

# Test ElevenLabs (if API key is set)
ELEVENLABS_API_KEY=your_key ./claude-hooks/utils/tts/elevenlabs_tts.py "Testing ElevenLabs voice"

# Test OpenAI (if API key is set)
OPENAI_API_KEY=your_key ./claude-hooks/utils/tts/openai_tts.py "Testing OpenAI voice"
```

## Recommendations

1. **For Best Quality**: ElevenLabs
   - Most natural sounding
   - Wide voice selection
   - Professional quality

2. **For Cost-Effectiveness**: OpenAI
   - Good quality
   - Included with ChatGPT Plus subscription
   - Natural sounding

3. **For Privacy/Offline**: pyttsx3
   - No data sent externally
   - Works without internet
   - Free forever

## Setting Your Preferred TTS

1. Choose your preferred service
2. Add the API key to your `.env` file
3. The hooks will automatically use it

Example `.env`:
```bash
# For ElevenLabs (highest priority)
ELEVENLABS_API_KEY=your_elevenlabs_key_here

# For OpenAI (second priority)
OPENAI_API_KEY=your_openai_key_here

# For specific engineer name
ENGINEER_NAME=Bernie
```

The hooks will automatically select the best available option based on your API keys.