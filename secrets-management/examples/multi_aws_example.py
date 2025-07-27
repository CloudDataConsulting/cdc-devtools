"""Example: Working with multiple AWS accounts simultaneously."""

import boto3
from typing import List, Dict
import logging
from pathlib import Path
import sys

# Add parent directory to path for imports
sys.path.append(str(Path(__file__).parent.parent.parent))

from secrets_management import CDCSecretsManager

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def multi_account_s3_operations():
    """Demonstrate working with multiple AWS accounts without conflicts."""
    
    # Initialize secrets manager
    secrets = CDCSecretsManager()
    
    logger.info("Getting credentials for multiple AWS accounts...")
    
    # Get credentials for different accounts
    prod_creds = secrets.get_aws_profile_config('prod')
    terraform_creds = secrets.get_aws_profile_config('terraform_backend')
    data_creds = secrets.get_aws_profile_config('data_source')
    
    # Create separate S3 clients - no environment variable conflicts!
    s3_prod = boto3.client('s3', **prod_creds)
    s3_terraform = boto3.client('s3', **terraform_creds)
    s3_data = boto3.client('s3', **data_creds)
    
    logger.info("Working with all three accounts simultaneously...")
    
    # Example 1: List buckets in each account
    print("\n=== Production Account Buckets ===")
    prod_buckets = s3_prod.list_buckets()
    for bucket in prod_buckets.get('Buckets', []):
        print(f"  - {bucket['Name']}")
    
    print("\n=== Terraform State Account Buckets ===")
    terraform_buckets = s3_terraform.list_buckets()
    for bucket in terraform_buckets.get('Buckets', []):
        print(f"  - {bucket['Name']}")
    
    print("\n=== Data Source Account Buckets ===")
    data_buckets = s3_data.list_buckets()
    for bucket in data_buckets.get('Buckets', []):
        print(f"  - {bucket['Name']}")
    
    # Example 2: Copy data between accounts
    logger.info("Example: Copying data from data source to production...")
    
    # Get object from data account
    try:
        data_object = s3_data.get_object(
            Bucket='data-lake-raw',
            Key='sample-data/users.csv'
        )
        
        # Put object in production account
        s3_prod.put_object(
            Bucket='prod-processed-data',
            Key='imported/users.csv',
            Body=data_object['Body'].read(),
            Metadata={
                'source': 'data-lake',
                'import-date': '2024-01-15'
            }
        )
        logger.info("Successfully copied data between accounts!")
        
    except Exception as e:
        logger.warning(f"Copy operation example failed (expected in demo): {e}")
    
    # Example 3: Backup terraform state
    logger.info("Example: Backing up terraform state...")
    
    try:
        # List terraform state files
        state_objects = s3_terraform.list_objects_v2(
            Bucket='terraform-state-bucket',
            Prefix='prod/'
        )
        
        for obj in state_objects.get('Contents', []):
            print(f"  Found state file: {obj['Key']}")
            
    except Exception as e:
        logger.warning(f"Terraform state example failed (expected in demo): {e}")


def cross_account_iam_example():
    """Demonstrate cross-account IAM operations."""
    
    secrets = CDCSecretsManager()
    
    # Get credentials
    prod_creds = secrets.get_aws_profile_config('prod')
    staging_creds = secrets.get_aws_profile_config('staging')
    
    # Create IAM clients
    iam_prod = boto3.client('iam', **prod_creds)
    iam_staging = boto3.client('iam', **staging_creds)
    
    # Example: List roles in each account
    print("\n=== Cross-Account IAM Example ===")
    
    try:
        # Production roles
        prod_roles = iam_prod.list_roles(MaxItems=5)
        print("\nProduction Account Roles:")
        for role in prod_roles.get('Roles', []):
            print(f"  - {role['RoleName']}")
        
        # Staging roles  
        staging_roles = iam_staging.list_roles(MaxItems=5)
        print("\nStaging Account Roles:")
        for role in staging_roles.get('Roles', []):
            print(f"  - {role['RoleName']}")
            
    except Exception as e:
        logger.warning(f"IAM example failed (may need permissions): {e}")


def parallel_operations_example():
    """Demonstrate parallel operations across accounts."""
    import concurrent.futures
    
    secrets = CDCSecretsManager()
    
    def check_bucket_versioning(profile_name: str) -> Dict[str, bool]:
        """Check S3 bucket versioning in an account."""
        creds = secrets.get_aws_profile_config(profile_name)
        s3 = boto3.client('s3', **creds)
        
        results = {}
        try:
            buckets = s3.list_buckets()
            for bucket in buckets.get('Buckets', [])[:3]:  # Check first 3 buckets
                try:
                    versioning = s3.get_bucket_versioning(Bucket=bucket['Name'])
                    results[bucket['Name']] = versioning.get('Status') == 'Enabled'
                except:
                    results[bucket['Name']] = False
        except Exception as e:
            logger.error(f"Error checking {profile_name}: {e}")
            
        return {profile_name: results}
    
    print("\n=== Parallel Multi-Account Operations ===")
    print("Checking S3 bucket versioning across all accounts...")
    
    # Run checks in parallel
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
        profiles = ['prod', 'staging', 'data_source']
        future_to_profile = {
            executor.submit(check_bucket_versioning, profile): profile
            for profile in profiles
        }
        
        for future in concurrent.futures.as_completed(future_to_profile):
            result = future.result()
            for profile, buckets in result.items():
                print(f"\n{profile.upper()} Account:")
                for bucket, versioned in buckets.items():
                    status = "✓ Enabled" if versioned else "✗ Disabled"
                    print(f"  - {bucket}: {status}")


if __name__ == "__main__":
    print("CDC Multi-Account AWS Example")
    print("=" * 50)
    
    # Check if config exists
    if not Path("config.yaml").exists():
        print("\nERROR: config.yaml not found!")
        print("Copy templates/config.yaml.example to config.yaml and configure your secrets.")
        sys.exit(1)
    
    try:
        # Run examples
        multi_account_s3_operations()
        cross_account_iam_example()
        parallel_operations_example()
        
        print("\n✅ Multi-account operations completed successfully!")
        print("\nKey Benefits Demonstrated:")
        print("- No environment variable conflicts")
        print("- Simultaneous access to multiple accounts")
        print("- Clear credential management")
        print("- Parallel operations across accounts")
        
    except Exception as e:
        logger.error(f"Example failed: {e}")
        print("\nMake sure:")
        print("1. config.yaml is properly configured")
        print("2. 1Password CLI is installed and authenticated")
        print("3. AWS credentials in 1Password are valid")