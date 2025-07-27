#!/usr/bin/env python3
"""
CDC Slack Notifications
Send monitoring alerts and notifications to Slack channels
"""

import os
import sys
import json
import logging
from datetime import datetime
from typing import Dict, List, Optional
import requests

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] [%(levelname)s] %(message)s'
)
logger = logging.getLogger(__name__)


class SlackNotifier:
    """Send notifications to Slack channels"""
    
    def __init__(self, webhook_url: Optional[str] = None):
        """Initialize Slack notifier with webhook URL"""
        self.webhook_url = webhook_url or os.getenv('CDC_SLACK_WEBHOOK_URL')
        if not self.webhook_url:
            raise ValueError("Slack webhook URL not provided")
    
    def send_message(self, text: str, channel: Optional[str] = None) -> bool:
        """Send a simple text message to Slack"""
        payload = {
            "text": text
        }
        if channel:
            payload["channel"] = channel
        
        return self._send_payload(payload)
    
    def send_alert(self, 
                   title: str, 
                   message: str, 
                   severity: str = "warning",
                   details: Optional[Dict] = None) -> bool:
        """Send a formatted alert to Slack"""
        color_map = {
            "info": "#36a64f",
            "warning": "#ff9800",
            "error": "#ff0000",
            "critical": "#990000"
        }
        
        attachment = {
            "color": color_map.get(severity, "#808080"),
            "title": f"CDC Alert: {title}",
            "text": message,
            "footer": "CDC Monitoring",
            "ts": int(datetime.now().timestamp())
        }
        
        if details:
            fields = []
            for key, value in details.items():
                fields.append({
                    "title": key,
                    "value": str(value),
                    "short": True
                })
            attachment["fields"] = fields
        
        payload = {
            "attachments": [attachment]
        }
        
        return self._send_payload(payload)
    
    def send_session_summary(self, sessions: List[Dict]) -> bool:
        """Send a summary of active sessions"""
        if not sessions:
            return self.send_message("No active CDC sessions")
        
        blocks = [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": f"CDC Active Sessions ({len(sessions)})"
                }
            }
        ]
        
        for session in sessions:
            blocks.append({
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": f"*Session:* {session['name']}"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*Status:* {session['status']}"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*Duration:* {session.get('duration', 'N/A')}"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*Health:* {session.get('health', 'Unknown')}"
                    }
                ]
            })
        
        payload = {
            "blocks": blocks
        }
        
        return self._send_payload(payload)
    
    def _send_payload(self, payload: Dict) -> bool:
        """Send payload to Slack webhook"""
        try:
            response = requests.post(
                self.webhook_url,
                json=payload,
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 200:
                logger.info("Notification sent successfully")
                return True
            else:
                logger.error(f"Failed to send notification: {response.status_code}")
                return False
                
        except Exception as e:
            logger.error(f"Error sending notification: {e}")
            return False


def main():
    """CLI interface for sending Slack notifications"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Send CDC notifications to Slack')
    parser.add_argument('--webhook-url', help='Slack webhook URL')
    parser.add_argument('--message', '-m', help='Message to send')
    parser.add_argument('--alert', '-a', action='store_true', help='Send as alert')
    parser.add_argument('--title', '-t', help='Alert title')
    parser.add_argument('--severity', '-s', choices=['info', 'warning', 'error', 'critical'],
                       default='warning', help='Alert severity')
    
    args = parser.parse_args()
    
    # Initialize notifier
    try:
        notifier = SlackNotifier(args.webhook_url)
    except ValueError as e:
        logger.error(f"Initialization error: {e}")
        logger.info("Set CDC_SLACK_WEBHOOK_URL environment variable or use --webhook-url")
        sys.exit(1)
    
    # Send notification
    if args.alert:
        if not args.title:
            logger.error("Alert title required with --alert")
            sys.exit(1)
        
        success = notifier.send_alert(
            title=args.title,
            message=args.message or "Alert triggered",
            severity=args.severity
        )
    else:
        if not args.message:
            logger.error("Message required")
            sys.exit(1)
        
        success = notifier.send_message(args.message)
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()