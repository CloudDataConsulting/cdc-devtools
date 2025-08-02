#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///

import sys
import os
import subprocess
import time
from pathlib import Path

# Import functions from our hooks
sys.path.insert(0, str(Path(__file__).parent))
from stop import get_completion_messages, extract_project_name, get_tts_script_path
from subagent_stop import get_subagent_completion_messages
from notification import announce_notification

def test_stop_hook():
    """Test the stop hook TTS messages."""
    print("\n🔊 Testing STOP hook messages...")
    
    # Get current project name
    cwd = os.getcwd()
    project_name = extract_project_name(cwd)
    print(f"Project: {project_name or 'None detected'}")
    
    # Get TTS script
    tts_script = get_tts_script_path()
    if not tts_script:
        print("❌ No TTS script available")
        return
    
    # Get sample messages
    messages = get_completion_messages(project_name)
    
    # Play first message
    message = messages[0]
    print(f"Playing: '{message}'")
    
    try:
        subprocess.run([
            "uv", "run", tts_script, message
        ], timeout=15)
    except Exception as e:
        print(f"Error: {e}")


def test_subagent_stop_hook():
    """Test the subagent stop hook TTS messages."""
    print("\n🔊 Testing SUBAGENT STOP hook messages...")
    
    # Get current project name
    cwd = os.getcwd()
    project_name = extract_project_name(cwd)
    agent_type = "software-engineer"  # Example agent type
    print(f"Project: {project_name or 'None detected'}")
    print(f"Agent Type: {agent_type}")
    
    # Get TTS script
    tts_script = get_tts_script_path()
    if not tts_script:
        print("❌ No TTS script available")
        return
    
    # Get sample messages
    messages = get_subagent_completion_messages(project_name, agent_type)
    
    # Play first message
    message = messages[0]
    print(f"Playing: '{message}'")
    
    try:
        subprocess.run([
            "uv", "run", tts_script, message
        ], timeout=15)
    except Exception as e:
        print(f"Error: {e}")


def test_notification_hook():
    """Test the notification hook TTS messages."""
    print("\n🔊 Testing NOTIFICATION hook messages...")
    
    # Get current project name
    cwd = os.getcwd()
    project_name = extract_project_name(cwd)
    print(f"Project: {project_name or 'None detected'}")
    
    # Test the announce_notification function directly
    # This will use the project name we pass
    announce_notification(project_name)
    print("Notification played (if TTS available)")


def test_custom_message(message):
    """Test a custom message."""
    print(f"\n🔊 Testing custom message: '{message}'")
    
    # Get TTS script
    tts_script = get_tts_script_path()
    if not tts_script:
        print("❌ No TTS script available")
        return
    
    try:
        subprocess.run([
            "uv", "run", tts_script, message
        ], timeout=15)
    except Exception as e:
        print(f"Error: {e}")


def main():
    """Main test function."""
    print("🎙️  Claude Hooks TTS Test Utility")
    print("=" * 50)
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == "stop":
            test_stop_hook()
        elif command == "subagent":
            test_subagent_stop_hook()
        elif command == "notification" or command == "notify":
            test_notification_hook()
        elif command == "custom" and len(sys.argv) > 2:
            custom_text = " ".join(sys.argv[2:])
            test_custom_message(custom_text)
        else:
            print("Unknown command. Use: stop, subagent, notification, or custom <text>")
    else:
        print("Testing all hooks with 3-second delays...\n")
        
        test_stop_hook()
        time.sleep(3)
        
        test_subagent_stop_hook()
        time.sleep(3)
        
        test_notification_hook()
        
        print("\n" + "=" * 50)
        print("✅ All tests complete!")
        print("\nUsage:")
        print("  ./test_tts.py stop          # Test stop hook")
        print("  ./test_tts.py subagent      # Test subagent stop hook")
        print("  ./test_tts.py notification  # Test notification hook")
        print("  ./test_tts.py custom <text> # Test custom message")


if __name__ == "__main__":
    main()