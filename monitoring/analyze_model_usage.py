#!/usr/bin/env python3
"""Analyze model usage and provide optimization recommendations."""

import sys
import os

# Add parent directory to path to import ai_agents module
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from ai_agents.base_agents.usage_tracker import UsageTracker


def main():
    tracker = UsageTracker()

    # Get analysis period from args
    days = int(sys.argv[1]) if len(sys.argv) > 1 else 7

    print(f"=== Model Usage Analysis (Last {days} days) ===\n")

    try:
        stats = tracker.analyze_usage(days)

        print(f"Opus Usage:")
        print(f"  Requests: {stats['opus']['count']}")
        print(f"  Success Rate: {stats['opus']['success_rate']:.2%}")
        print(f"  Total Tokens: {stats['opus']['tokens']:,}")

        print(f"\nSonnet Usage:")
        print(f"  Requests: {stats['sonnet']['count']}")
        print(f"  Success Rate: {stats['sonnet']['success_rate']:.2%}")
        print(f"  Total Tokens: {stats['sonnet']['tokens']:,}")

        print(f"\nTask Distribution:")
        for task, counts in stats['task_distribution'].items():
            print(f"  {task}: Opus={counts['opus']}, Sonnet={counts['sonnet']}")

        print(f"\nOptimization Opportunities:")
        recommendations = tracker.get_recommendations()
        if recommendations:
            for rec in recommendations:
                print(f"  - {rec}")
        else:
            print("  No specific recommendations at this time")

        if stats['potential_savings'] > 0:
            print(f"\n💰 Potential Opus requests that could use Sonnet: {stats['potential_savings']}")

    except FileNotFoundError:
        print("No usage data found. Model usage will be tracked as agents run.")
        print("\nTo test the system:")
        print("1. Run AI agents that inherit from ModelAwareAgent")
        print("2. Usage data will be logged to ./usage_metrics.jsonl")
        print("3. Run this script again to see analytics")


if __name__ == "__main__":
    main()