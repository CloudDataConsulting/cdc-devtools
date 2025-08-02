#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///

import subprocess
import json
import time
import sys

def simulate_stop_hook(session_id="test-session"):
    """Simulate a stop hook call."""
    data = {
        "session_id": session_id,
        "transcript_path": "/tmp/test.jsonl",
        "cwd": "/Users/bpruss/repos/cdc/cdc-devtools",
        "hook_event_name": "Stop",
        "stop_hook_active": False
    }
    
    proc = subprocess.Popen(
        ["./stop.py"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    
    stdout, stderr = proc.communicate(input=json.dumps(data))
    return proc.returncode


def main():
    print("🧪 Testing deduplication of TTS announcements...")
    print("=" * 50)
    
    print("\n1. Simulating 3 rapid stop hook calls (should only hear 1 announcement)...")
    
    for i in range(3):
        print(f"   Call {i+1}...", end="", flush=True)
        simulate_stop_hook()
        print(" done")
        time.sleep(0.5)  # Small delay between calls
    
    print("\n2. Waiting 6 seconds...")
    time.sleep(6)
    
    print("\n3. Another stop hook call (should hear announcement again)...")
    simulate_stop_hook()
    print("   done")
    
    print("\n✅ Test complete!")


if __name__ == "__main__":
    main()