#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///

import sys
import os
sys.path.insert(0, '.')

from stop import extract_project_name, get_tts_script_path
import subprocess

def test_ai_pronunciation():
    """Test AI pronunciation in project names."""
    
    test_cases = [
        "/Users/test/cdc-ai",
        "/Users/test/cdc-ai-site", 
        "/Users/test/myproject-api",
        "/Users/test/ui-dashboard",
        "/Users/test/ml-pipeline",
        "/Users/test/data-etl"
    ]
    
    print("🧪 Testing AI and acronym pronunciation...")
    print("=" * 50)
    
    for path in test_cases:
        project_name = extract_project_name(path)
        print(f"Path: {path}")
        print(f"Extracted: '{project_name}'")
        
        # Test TTS if available
        tts_script = get_tts_script_path()
        if tts_script and project_name:
            message = f"Work complete on {project_name}!"
            print(f"TTS Message: '{message}'")
            
            try:
                subprocess.run([
                    "uv", "run", tts_script, message
                ], timeout=10)
            except Exception as e:
                print(f"TTS Error: {e}")
        
        print("-" * 30)

if __name__ == "__main__":
    test_ai_pronunciation()