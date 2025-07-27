"""
CDC Secrets Management - Pull secrets on demand from 1Password
"""
import yaml
import subprocess
import json
from typing import Dict, Any, Optional, List
from pathlib import Path
import logging

logger = logging.getLogger(__name__)


class CDCSecretsManager:
    """Manage secrets retrieval from 1Password based on config."""

    def __init__(self, config_path: str = "config.yaml"):
        self.config_path = Path(config_path)
        self.config = self._load_config()
        self._secrets_cache = {}
        
    def _load_config(self) -> Dict[str, Any]:
        """Load project configuration."""
        if not self.config_path.exists():
            # Try alternative paths
            alt_paths = [
                Path(".cdc-project.yaml"),
                Path("configs/config.yaml"),
                Path(".cdc/config.yaml")
            ]
            for alt_path in alt_paths:
                if alt_path.exists():
                    self.config_path = alt_path
                    break
            else:
                raise FileNotFoundError(
                    f"Config not found. Tried: {self.config_path}, " + 
                    ", ".join(str(p) for p in alt_paths)
                )
        
        with open(self.config_path) as f:
            return yaml.safe_load(f)
    
    def _find_secret_config(self, secret_path: str) -> Dict[str, Any]:
        """Navigate config structure to find secret configuration."""
        parts = secret_path.split('.')
        current = self.config.get('secrets', {})
        
        for part in parts:
            if isinstance(current, dict) and part in current:
                current = current[part]
            else:
                raise KeyError(f"Secret path not found in config: {secret_path}")
        
        if not isinstance(current, dict) or 'item' not in current:
            raise ValueError(f"Invalid secret config at {secret_path}. Must have 'item' field.")
        
        return current
    
    def _retrieve_from_1password(self, vault: str, item: str, field: str = "password") -> str:
        """Retrieve a secret from 1Password using op CLI."""
        try:
            # Build 1Password reference
            # Using path format for better readability
            op_ref = f"op://{vault}/{item}/{field}"
            
            # Call op CLI
            result = subprocess.run(
                ["op", "read", op_ref],
                capture_output=True,
                text=True,
                check=True
            )
            
            return result.stdout.strip()
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to retrieve secret from 1Password: {e.stderr}")
            raise RuntimeError(f"1Password retrieval failed: {e.stderr}")
    
    def get_secret(self, secret_name: str, vault: Optional[str] = None) -> str:
        """
        Retrieve a secret from 1Password.
        
        Example config.yaml:
        secrets:
          aws_profiles:
            prod:
              vault: "CDC_Production"
              item: "AWS-Production"
              field: "access_key"
            terraform_backend:
              vault: "CDC_Infrastructure"
              item: "AWS-Terraform-Backend"
              field: "access_key"
        """
        # Check cache first
        cache_key = f"{vault}:{secret_name}" if vault else secret_name
        if cache_key in self._secrets_cache:
            return self._secrets_cache[cache_key]
        
        # Get from config
        secret_config = self._find_secret_config(secret_name)
        
        # Retrieve from 1Password
        secret_value = self._retrieve_from_1password(
            vault=secret_config.get('vault', vault),
            item=secret_config['item'],
            field=secret_config.get('field', 'password')
        )
        
        # Cache it
        self._secrets_cache[cache_key] = secret_value
        return secret_value
    
    def get_aws_profile_config(self, profile_name: str) -> Dict[str, str]:
        """Get AWS credentials for a specific profile."""
        profile_path = f"aws_profiles.{profile_name}"
        profile_config = self._find_secret_config(profile_path)
        
        # Get the credentials
        creds = {
            'aws_access_key_id': self._retrieve_from_1password(
                vault=profile_config['vault'],
                item=profile_config['item'],
                field=profile_config.get('access_key_field', 'access_key')
            ),
            'aws_secret_access_key': self._retrieve_from_1password(
                vault=profile_config['vault'],
                item=profile_config['item'],
                field=profile_config.get('secret_key_field', 'secret_key')
            ),
            'region_name': profile_config.get('region', 'us-east-1')
        }
        
        # Add optional fields
        if 'role_arn' in profile_config:
            creds['role_arn'] = profile_config['role_arn']
            
        return creds
    
    def get_database_config(self, db_name: str) -> Dict[str, str]:
        """Get database connection configuration."""
        db_path = f"databases.{db_name}"
        db_config = self._find_secret_config(db_path)
        
        result = {}
        
        # Handle different field configurations
        if 'fields' in db_config:
            # Multiple fields from same item
            for field_name in db_config['fields']:
                result[field_name] = self._retrieve_from_1password(
                    vault=db_config['vault'],
                    item=db_config['item'],
                    field=field_name
                )
        else:
            # Single field or default password
            result['password'] = self._retrieve_from_1password(
                vault=db_config['vault'],
                item=db_config['item'],
                field=db_config.get('field', 'password')
            )
            
            # Add any static config values
            for key, value in db_config.items():
                if key not in ['vault', 'item', 'field', 'fields']:
                    result[key] = value
        
        return result
    
    def get_api_key(self, api_name: str) -> str:
        """Get an API key."""
        api_path = f"api_keys.{api_name}"
        api_config = self._find_secret_config(api_path)
        
        return self._retrieve_from_1password(
            vault=api_config['vault'],
            item=api_config['item'],
            field=api_config.get('field', 'api_key')
        )
    
    def list_available_secrets(self) -> Dict[str, List[str]]:
        """List all available secrets defined in config."""
        secrets = self.config.get('secrets', {})
        available = {}
        
        for category, items in secrets.items():
            if isinstance(items, dict):
                available[category] = list(items.keys())
        
        return available
    
    def clear_cache(self):
        """Clear the secrets cache."""
        self._secrets_cache.clear()
        logger.info("Secrets cache cleared")