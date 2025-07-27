"""Track and analyze model usage for optimization."""

import json
from datetime import datetime, timedelta
from collections import defaultdict
from typing import Dict, List, Tuple


class UsageTracker:
    """Track model usage and provide insights."""

    def __init__(self, log_path: str = './usage_metrics.jsonl'):
        self.log_path = log_path

    def log_usage(
        self,
        model: str,
        task_type: str,
        tokens_used: int,
        success: bool,
        duration_seconds: float
    ):
        """Log usage metrics."""
        entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "model": model,
            "task_type": task_type,
            "tokens_used": tokens_used,
            "success": success,
            "duration_seconds": duration_seconds
        }

        with open(self.log_path, 'a') as f:
            f.write(json.dumps(entry) + '\n')

    def analyze_usage(self, days: int = 7) -> Dict:
        """Analyze recent usage patterns."""
        cutoff = datetime.utcnow() - timedelta(days=days)

        stats = {
            "opus": {"count": 0, "tokens": 0, "success_rate": 0},
            "sonnet": {"count": 0, "tokens": 0, "success_rate": 0},
            "task_distribution": defaultdict(lambda: {"opus": 0, "sonnet": 0}),
            "potential_savings": 0
        }

        opus_successes = []
        sonnet_successes = []

        with open(self.log_path, 'r') as f:
            for line in f:
                entry = json.loads(line)
                timestamp = datetime.fromisoformat(entry["timestamp"])

                if timestamp < cutoff:
                    continue

                model_key = "opus" if "opus" in entry["model"] else "sonnet"
                stats[model_key]["count"] += 1
                stats[model_key]["tokens"] += entry.get("tokens_used", 0)

                if model_key == "opus":
                    opus_successes.append(entry["success"])
                else:
                    sonnet_successes.append(entry["success"])

                task = entry.get("task_type", "unknown")
                stats["task_distribution"][task][model_key] += 1

        # Calculate success rates
        if opus_successes:
            stats["opus"]["success_rate"] = sum(opus_successes) / len(opus_successes)
        if sonnet_successes:
            stats["sonnet"]["success_rate"] = sum(sonnet_successes) / len(sonnet_successes)

        # Identify optimization opportunities
        for task, counts in stats["task_distribution"].items():
            if counts["opus"] > counts["sonnet"] and task in ["log_analysis", "generate_summary", "file_operation"]:
                stats["potential_savings"] += counts["opus"]

        return stats

    def get_recommendations(self) -> List[str]:
        """Get recommendations for model usage optimization."""
        stats = self.analyze_usage()
        recommendations = []

        if stats["potential_savings"] > 10:
            recommendations.append(
                f"Consider moving {stats['potential_savings']} simple tasks from Opus to Sonnet"
            )

        # Check success rates
        opus_rate = stats["opus"]["success_rate"]
        sonnet_rate = stats["sonnet"]["success_rate"]

        if sonnet_rate > 0.95 and opus_rate < sonnet_rate:
            recommendations.append(
                "Sonnet is performing very well - consider expanding its usage"
            )

        return recommendations