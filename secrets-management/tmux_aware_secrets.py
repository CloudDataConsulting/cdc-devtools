"""Tmux-aware secrets management."""
import os
from typing import Optional, Dict, Any
import logging

from .base_secrets_manager import CDCSecretsManager

logger = logging.getLogger(__name__)


class TmuxAwareSecretsManager(CDCSecretsManager):
    """Secrets manager that respects tmux window contexts."""
    
    def __init__(self, config_path: Optional[str] = None):
        """
        Initialize with config path, respecting tmux window context.
        
        Args:
            config_path: Path to config file. If None, checks CDC_CONFIG_PATH env var.
        """
        # Check if running in tmux window with specific config
        if config_path is None:
            config_path = os.environ.get('CDC_CONFIG_PATH', 'config.yaml')
        
        # Show which config is being used if in tmux
        if 'TMUX_PANE' in os.environ:
            pane = os.environ.get('TMUX_PANE', '')
            window = os.environ.get('TMUX_WINDOW', '')
            logger.info(f"🔐 Tmux pane {pane} (window {window}) using config: {config_path}")
        
        super().__init__(config_path)
        
        # Store tmux context
        self.tmux_pane = os.environ.get('TMUX_PANE')
        self.tmux_window = os.environ.get('TMUX_WINDOW')
        self.is_tmux = bool(self.tmux_pane)
    
    @classmethod
    def for_current_window(cls) -> 'TmuxAwareSecretsManager':
        """
        Create manager for current tmux window's config.
        
        This factory method makes it easy to get the right config
        for the current tmux window context.
        """
        return cls()
    
    @classmethod
    def for_aws_profile(cls, profile_name: str) -> 'TmuxAwareSecretsManager':
        """
        Create manager optimized for a specific AWS profile.
        
        Args:
            profile_name: AWS profile to optimize for
            
        Returns:
            TmuxAwareSecretsManager configured for the profile
        """
        # Check if there's a profile-specific config
        profile_config = f"configs/{profile_name}-config.yaml"
        if os.path.exists(profile_config):
            return cls(profile_config)
        
        # Otherwise use default
        manager = cls()
        manager._default_aws_profile = profile_name
        return manager
    
    def get_aws_profile_config(self, profile_name: Optional[str] = None) -> Dict[str, str]:
        """
        Get AWS profile config, with tmux window awareness.
        
        Args:
            profile_name: Profile name. If None, uses window default.
        """
        # Check for window-specific default profile
        if profile_name is None and hasattr(self, '_default_aws_profile'):
            profile_name = self._default_aws_profile
        
        # Check environment for profile hint
        if profile_name is None:
            profile_name = os.environ.get('CDC_AWS_PROFILE', 'default')
        
        return super().get_aws_profile_config(profile_name)
    
    def get_window_context(self) -> Dict[str, Any]:
        """Get information about current tmux window context."""
        context = {
            'is_tmux': self.is_tmux,
            'config_path': str(self.config_path),
            'available_secrets': self.list_available_secrets()
        }
        
        if self.is_tmux:
            context.update({
                'tmux_pane': self.tmux_pane,
                'tmux_window': self.tmux_window,
                'window_name': os.environ.get('TMUX_WINDOW_NAME', 'unknown')
            })
        
        return context
    
    def validate_window_config(self) -> bool:
        """
        Validate that the current window has appropriate config.
        
        Returns:
            True if config is valid for window context
        """
        if not self.config_path.exists():
            logger.error(f"Config file not found: {self.config_path}")
            return False
        
        # Check if running in tmux
        if self.is_tmux:
            window_name = os.environ.get('TMUX_WINDOW_NAME', '').lower()
            
            # Validate config matches window purpose
            if 'prod' in window_name and 'prod' not in str(self.config_path).lower():
                logger.warning(
                    f"Window '{window_name}' using non-production config: {self.config_path}"
                )
            
            if 'terraform' in window_name:
                # Check for terraform backend profile
                terraform_config = self.config.get('tools', {}).get('terraform', {})
                if 'backend_profile' not in terraform_config:
                    logger.warning(
                        "Terraform window but no backend_profile in config"
                    )
        
        return True
    
    def switch_config(self, new_config_path: str) -> None:
        """
        Switch to a different config file.
        
        Useful for changing contexts within a tmux window.
        
        Args:
            new_config_path: Path to new config file
        """
        logger.info(f"Switching config from {self.config_path} to {new_config_path}")
        
        # Clear cache
        self.clear_cache()
        
        # Reload with new config
        self.config_path = Path(new_config_path)
        self.config = self._load_config()
        
        # Update environment
        os.environ['CDC_CONFIG_PATH'] = new_config_path
        
        logger.info(f"Switched to config: {new_config_path}")


# Convenience functions for tmux integration
def get_secrets_for_window() -> TmuxAwareSecretsManager:
    """
    Get secrets manager for current tmux window.
    
    This is a convenience function that automatically uses
    the right config for the current tmux window.
    """
    return TmuxAwareSecretsManager.for_current_window()


def setup_window_secrets(window_name: str, config_path: str) -> None:
    """
    Setup secrets configuration for a specific tmux window.
    
    Args:
        window_name: Name of tmux window
        config_path: Path to config file for this window
    """
    if 'TMUX' not in os.environ:
        logger.warning("Not in a tmux session")
        return
    
    # This would typically be called from shell/tmux scripts
    os.environ['CDC_CONFIG_PATH'] = config_path
    logger.info(f"Window '{window_name}' configured with: {config_path}")


# Example usage in scripts
if __name__ == "__main__":
    # Example: Show current window configuration
    manager = TmuxAwareSecretsManager.for_current_window()
    context = manager.get_window_context()
    
    print("Current Window Context:")
    print("=" * 50)
    for key, value in context.items():
        print(f"{key}: {value}")
    
    if manager.validate_window_config():
        print("\n✅ Configuration is valid for this window")
    else:
        print("\n❌ Configuration may not be appropriate for this window")