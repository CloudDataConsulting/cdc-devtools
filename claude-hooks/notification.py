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

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv is optional


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
        
        return project_name
    return None


def announce_notification(project_name=None, session_id=None):
    """Announce that the agent needs user input."""
    try:
        # Check for recent announcements to prevent duplicates
        if session_id:
            last_announce_file = Path("/tmp") / f".claude_notify_announce_{session_id}"
            
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
        
        # Get engineer name if available
        engineer_name = os.getenv('ENGINEER_NAME', '').strip()
        
        # Create notification message with variations
        messages = []
        base_messages = [
            "Your agent needs your input",
            "Agent is waiting for your response",
            "Ready for your next instruction"
        ]
        
        # Add project-specific variations if project name is available
        if project_name:
            messages.extend([
                f"Your {project_name} agent needs input",
                f"Agent working on {project_name} needs your response",
                f"{project_name} is waiting for your instruction"
            ])
        
        # Add personalized variations if engineer name is available
        if engineer_name:
            if project_name:
                messages.extend([
                    f"{engineer_name}, your {project_name} agent needs input",
                    f"{engineer_name}, {project_name} is ready for your next step"
                ])
            else:
                messages.extend([
                    f"{engineer_name}, your agent needs your input",
                    f"{engineer_name}, agent is waiting for you"
                ])
        
        # If we have both basic and enhanced messages, prefer enhanced ones
        if len(messages) > len(base_messages):
            # 70% chance to use enhanced messages
            if random.random() < 0.7:
                notification_message = random.choice(messages[len(base_messages):])
            else:
                notification_message = random.choice(messages[:len(base_messages)])
        else:
            # Fall back to basic messages
            notification_message = random.choice(base_messages if messages else ["Your agent needs your input"])
        
        # Call the TTS script with the notification message
        subprocess.run([
            "uv", "run", tts_script, notification_message
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
        parser.add_argument('--notify', action='store_true', help='Enable TTS notifications')
        args = parser.parse_args()
        
        # Read JSON input from stdin
        input_data = json.loads(sys.stdin.read())
        
        # Ensure log directory exists
        import os
        log_dir = os.path.join(os.getcwd(), 'logs')
        os.makedirs(log_dir, exist_ok=True)
        log_file = os.path.join(log_dir, 'notification.json')
        
        # Read existing log data or initialize empty list
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                try:
                    log_data = json.load(f)
                except (json.JSONDecodeError, ValueError):
                    log_data = []
        else:
            log_data = []
        
        # Append new data
        log_data.append(input_data)
        
        # Write back to file with formatting
        with open(log_file, 'w') as f:
            json.dump(log_data, f, indent=2)
        
        # Extract project name from cwd and session_id
        cwd = input_data.get("cwd", "")
        project_name = extract_project_name(cwd)
        session_id = input_data.get("session_id", "")
        
        # Announce notification via TTS only if --notify flag is set
        # Skip TTS for the generic "Claude is waiting for your input" message
        if args.notify and input_data.get('message') != 'Claude is waiting for your input':
            announce_notification(project_name, session_id)
        
        sys.exit(0)
        
    except json.JSONDecodeError:
        # Handle JSON decode errors gracefully
        sys.exit(0)
    except Exception:
        # Handle any other errors gracefully
        sys.exit(0)

if __name__ == '__main__':
    main()