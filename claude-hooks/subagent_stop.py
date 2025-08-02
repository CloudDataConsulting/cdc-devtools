#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///

import argparse
import json
import os
import sys
import subprocess
import random
import time
from pathlib import Path
from datetime import datetime

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv is optional


def get_subagent_completion_messages(project_name=None, agent_type=None):
    """Return list of friendly subagent completion messages."""
    if project_name and agent_type:
        return [
            f"{agent_type} agent finished working on {project_name}!",
            f"{project_name}: {agent_type} agent task complete!",
            f"{agent_type} agent done with {project_name} updates!",
            f"Successfully completed {agent_type} tasks for {project_name}!",
            f"{project_name} looking good thanks to {agent_type} agent!"
        ]
    elif agent_type:
        return [
            f"{agent_type} agent task complete!",
            f"{agent_type} agent finished!",
            f"{agent_type} agent work done!",
            f"{agent_type} agent ready!",
            f"{agent_type} agent task accomplished!"
        ]
    elif project_name:
        return [
            f"Subagent task complete on {project_name}!",
            f"Subagent finished with {project_name}!",
            f"{project_name} subagent work done!",
            f"Subagent ready for more {project_name} tasks!",
            f"{project_name} subagent task accomplished!"
        ]
    else:
        return [
            "Subagent task complete!",
            "Subagent finished!",
            "Subagent work done!",
            "Subagent ready!",
            "Subagent task accomplished!"
        ]


def extract_project_name(cwd):
    """Extract project name from the current working directory path."""
    if not cwd:
        return None
    
    # Get the last directory name from the path
    path_parts = cwd.rstrip('/').split('/')
    if path_parts:
        project_name = path_parts[-1]
        # Clean up common prefixes/suffixes
        if project_name.startswith('.'):
            return None  # Hidden directories
        
        # Remove 'cdc-' prefix for cleaner TTS
        if project_name.lower().startswith('cdc-'):
            project_name = project_name[4:]
        
        # Convert hyphens to spaces and title case for better speech
        project_name = project_name.replace('-', ' ').title()
        
        # Apply pronunciation fixes for TTS
        pronunciation_map = {
            'Ai': 'A I',  # So "AI" gets pronounced as "A I" instead of "ah"
            'Api': 'A P I',  # API -> "A P I"
            'Ui': 'U I',  # UI -> "U I" 
            'Ml': 'M L',  # ML -> "M L"
            'Nlp': 'N L P',  # NLP -> "N L P"
            'Sql': 'S Q L',  # SQL -> "S Q L"
            'Etl': 'E T L',  # ETL -> "E T L"
            'Aws': 'A W S',  # AWS -> "A W S"
            'Gcp': 'G C P',  # GCP -> "G C P"
            'Iot': 'I O T',  # IoT -> "I O T"
        }
        
        # Apply pronunciation mappings
        for word, pronunciation in pronunciation_map.items():
            project_name = project_name.replace(word, pronunciation)
        
        return project_name
    return None


def get_tts_script_path():
    """
    Determine which TTS script to use based on available API keys.
    Priority order: ElevenLabs > OpenAI > pyttsx3
    """
    # Get current script directory and construct utils/tts path
    script_dir = Path(__file__).parent
    tts_dir = script_dir / "utils" / "tts"
    
    # Check for ElevenLabs API key (highest priority)
    if os.getenv('ELEVENLABS_API_KEY'):
        elevenlabs_script = tts_dir / "elevenlabs_tts.py"
        if elevenlabs_script.exists():
            return str(elevenlabs_script)
    
    # Check for OpenAI API key (second priority)
    if os.getenv('OPENAI_API_KEY'):
        openai_script = tts_dir / "openai_tts.py"
        if openai_script.exists():
            return str(openai_script)
    
    # Fall back to pyttsx3 (no API key required)
    pyttsx3_script = tts_dir / "pyttsx3_tts.py"
    if pyttsx3_script.exists():
        return str(pyttsx3_script)
    
    return None


def announce_subagent_completion(project_name=None, agent_type=None, session_id=None):
    """Announce subagent completion using the best available TTS service."""
    try:
        # Check for recent announcements to prevent duplicates
        if session_id:
            last_announce_file = Path("/tmp") / f".claude_subagent_announce_{session_id}"
            
            # Check if we've announced recently (within 5 seconds)
            if last_announce_file.exists():
                last_time = last_announce_file.stat().st_mtime
                if time.time() - last_time < 5:
                    return  # Skip duplicate announcement
            
            # Update timestamp
            last_announce_file.touch()
        
        tts_script = get_tts_script_path()
        if not tts_script:
            return  # No TTS scripts available
        
        # Get random completion message
        messages = get_subagent_completion_messages(project_name, agent_type)
        completion_message = random.choice(messages)
        
        # Call the TTS script with the completion message
        subprocess.run([
            "uv", "run", tts_script, completion_message
        ], 
        capture_output=True,  # Suppress output
        timeout=10  # 10-second timeout
        )
        
    except (subprocess.TimeoutExpired, subprocess.SubprocessError, FileNotFoundError):
        # Fail silently if TTS encounters issues
        pass
    except Exception:
        # Fail silently for any other errors
        pass


def main():
    try:
        # Parse command line arguments
        parser = argparse.ArgumentParser()
        parser.add_argument('--chat', action='store_true', help='Copy transcript to chat.json')
        args = parser.parse_args()
        
        # Read JSON input from stdin
        input_data = json.load(sys.stdin)

        # Extract required fields
        session_id = input_data.get("session_id", "")
        stop_hook_active = input_data.get("stop_hook_active", False)

        # Ensure log directory exists in project root
        # Get the current working directory from input_data (project root)
        project_root = input_data.get("cwd", os.getcwd())
        log_dir = os.path.join(project_root, "ai-logs")
        os.makedirs(log_dir, exist_ok=True)
        log_path = os.path.join(log_dir, "subagent_stop.json")

        # Read existing log data or initialize empty list
        if os.path.exists(log_path):
            with open(log_path, 'r') as f:
                try:
                    log_data = json.load(f)
                except (json.JSONDecodeError, ValueError):
                    log_data = []
        else:
            log_data = []
        
        # Append new data
        log_data.append(input_data)
        
        # Write back to file with formatting
        with open(log_path, 'w') as f:
            json.dump(log_data, f, indent=2)
        
        # Handle --chat switch (same as stop.py)
        if args.chat and 'transcript_path' in input_data:
            transcript_path = input_data['transcript_path']
            if os.path.exists(transcript_path):
                # Read .jsonl file and convert to JSON array
                chat_data = []
                try:
                    with open(transcript_path, 'r') as f:
                        for line in f:
                            line = line.strip()
                            if line:
                                try:
                                    chat_data.append(json.loads(line))
                                except json.JSONDecodeError:
                                    pass  # Skip invalid lines
                    
                    # Write to logs/chat.json
                    chat_file = os.path.join(log_dir, 'chat.json')
                    with open(chat_file, 'w') as f:
                        json.dump(chat_data, f, indent=2)
                except Exception:
                    pass  # Fail silently

        # Extract project name and agent type
        cwd = input_data.get("cwd", "")
        project_name = extract_project_name(cwd)
        agent_type = input_data.get("subagent_type", None)
        
        # Announce subagent completion via TTS
        announce_subagent_completion(project_name, agent_type, session_id)

        sys.exit(0)

    except json.JSONDecodeError:
        # Handle JSON decode errors gracefully
        sys.exit(0)
    except Exception:
        # Handle any other errors gracefully
        sys.exit(0)


if __name__ == "__main__":
    main()