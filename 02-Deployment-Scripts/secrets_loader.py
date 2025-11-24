#!/usr/bin/env python3
"""
secrets_loader.py

Secure secret management for Cowrie Discord monitor threat enrichment.
Supports two modes:
  1) Local dev: Load from /opt/cowrie/discord-monitor/.env (python-dotenv)
  2) Production: Optionally fetch from AWS Secrets Manager or SSM Parameter Store

Never logs or prints secret values. Only logs presence/absence and latency.
"""

import os
import logging
import json
import time
from typing import Optional, Dict, List

# Configure logging (safe - never logs secret values)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# In-memory secret store
_secrets: Dict[str, str] = {}


class SecretMissingError(Exception):
    """Raised when required secrets are missing"""
    pass


def load_env(env_path: str = "/opt/cowrie/discord-monitor/.env") -> bool:
    """
    Load secrets from .env file using python-dotenv.
    
    Args:
        env_path: Path to .env file (default: /opt/cowrie/discord-monitor/.env)
    
    Returns:
        bool: True if file exists and loaded, False otherwise
    """
    try:
        from dotenv import load_dotenv
        
        if not os.path.exists(env_path):
            logger.warning(f".env file not found at {env_path}")
            return False
        
        start = time.time()
        load_dotenv(env_path, override=True)
        elapsed = time.time() - start
        
        # Load into our secrets dict
        with open(env_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    if value:  # Only store non-empty values
                        _secrets[key] = value
        
        logger.info(f"✓ Loaded .env file ({len(_secrets)} keys found) in {elapsed:.3f}s")
        return True
        
    except ImportError:
        logger.warning("python-dotenv not installed. Install: pip install python-dotenv")
        return False
    except Exception as e:
        logger.error(f"Failed to load .env: {e}")
        return False


def load_from_aws(secret_name: Optional[str] = None) -> bool:
    """
    Load secrets from AWS Secrets Manager or SSM Parameter Store.
    Only runs if boto3 is available and AWS credentials are present.
    
    Args:
        secret_name: Name of AWS Secrets Manager secret (optional)
    
    Returns:
        bool: True if successfully loaded from AWS, False otherwise
    """
    if not secret_name:
        logger.info("No AWS secret name provided, skipping AWS secret retrieval")
        return False
    
    try:
        import boto3
        from botocore.exceptions import ClientError, NoCredentialsError
        
        start = time.time()
        
        # Try Secrets Manager first
        try:
            client = boto3.client('secretsmanager', region_name='us-east-1')
            response = client.get_secret_value(SecretId=secret_name)
            
            if 'SecretString' in response:
                secret_data = json.loads(response['SecretString'])
                _secrets.update(secret_data)
                elapsed = time.time() - start
                logger.info(f"✓ Loaded AWS Secrets Manager secret '{secret_name}' ({len(secret_data)} keys) in {elapsed:.3f}s")
                return True
                
        except ClientError as e:
            if e.response['Error']['Code'] == 'ResourceNotFoundException':
                logger.warning(f"AWS Secret '{secret_name}' not found in Secrets Manager")
            else:
                logger.warning(f"AWS Secrets Manager error: {e.response['Error']['Code']}")
        
        # Fallback to SSM Parameter Store
        try:
            ssm = boto3.client('ssm', region_name='us-east-1')
            response = ssm.get_parameter(Name=secret_name, WithDecryption=True)
            
            secret_value = response['Parameter']['Value']
            secret_data = json.loads(secret_value)
            _secrets.update(secret_data)
            elapsed = time.time() - start
            logger.info(f"✓ Loaded AWS SSM Parameter '{secret_name}' ({len(secret_data)} keys) in {elapsed:.3f}s")
            return True
            
        except ClientError as e:
            logger.warning(f"AWS SSM Parameter error: {e.response['Error']['Code']}")
            
    except ImportError:
        logger.info("boto3 not installed. AWS secret retrieval disabled. Install: pip install boto3")
        return False
    except NoCredentialsError:
        logger.info("No AWS credentials found. Skipping AWS secret retrieval.")
        return False
    except Exception as e:
        logger.error(f"Unexpected error loading from AWS: {type(e).__name__}")
        return False
    
    return False


def get(key: str, default: Optional[str] = None) -> Optional[str]:
    """
    Get a secret value by key.
    
    Args:
        key: Secret key name
        default: Default value if key not found
    
    Returns:
        Secret value or default
    """
    # Check our loaded secrets first
    if key in _secrets:
        return _secrets[key]
    
    # Fallback to environment variable
    value = os.getenv(key, default)
    if value:
        _secrets[key] = value  # Cache it
    
    return value


def validate_required(keys: List[str]) -> None:
    """
    Validate that required secrets are present.
    
    Args:
        keys: List of required secret keys
    
    Raises:
        SecretMissingError: If any required keys are missing
    """
    missing = []
    
    for key in keys:
        if not get(key):
            missing.append(key)
    
    if missing:
        # Log which keys are missing (safe - no values)
        logger.error(f"Missing required secrets: {', '.join(missing)}")
        raise SecretMissingError(f"Required secrets missing: {', '.join(missing)}")
    
    logger.info(f"✓ All required secrets validated ({len(keys)} keys)")


def check_optional(keys: List[str]) -> Dict[str, bool]:
    """
    Check which optional secrets are present.
    
    Args:
        keys: List of optional secret keys
    
    Returns:
        Dict mapping key name to presence (True/False)
    """
    result = {}
    for key in keys:
        result[key] = bool(get(key))
    return result


def get_all_keys() -> List[str]:
    """
    Get list of all loaded secret keys (not values).
    
    Returns:
        List of key names
    """
    return list(_secrets.keys())


def is_present(key: str) -> bool:
    """
    Check if a secret key is present without retrieving the value.
    
    Args:
        key: Secret key name
    
    Returns:
        bool: True if key exists, False otherwise
    """
    return bool(get(key))


# Safe summary for testing/debugging
if __name__ == "__main__":
    print("=" * 60)
    print("Secrets Loader - Safe Summary")
    print("=" * 60)
    
    # Load from .env
    env_loaded = load_env()
    print(f"\n.env file loaded: {env_loaded}")
    
    # Check for AWS secret name
    aws_secret_name = os.getenv("HONEYBOMB_AWS_SECRET")
    if aws_secret_name:
        aws_loaded = load_from_aws(aws_secret_name)
        print(f"AWS secret loaded: {aws_loaded}")
    else:
        print("AWS secret name not provided (HONEYBOMB_AWS_SECRET not set)")
    
    # Required keys for threat enrichment
    required_keys = [
        "ABUSEIPDB_KEY",
        "OTX_KEY",
        "IPINFO_KEY",
        "VIRUSTOTAL_KEY",
        "SHODAN_KEY"
    ]
    
    print(f"\n{'Key':<25} {'Present':<10}")
    print("-" * 35)
    
    for key in required_keys:
        present = is_present(key)
        status = "✓ Yes" if present else "✗ No"
        print(f"{key:<25} {status:<10}")
    
    print("\n" + "=" * 60)
    print(f"Total secrets loaded: {len(_secrets)}")
    print("=" * 60)
    
    # Try validation
    try:
        validate_required(required_keys)
        print("\n✓ All required secrets validated successfully!")
    except SecretMissingError as e:
        print(f"\n✗ Validation failed: {e}")
