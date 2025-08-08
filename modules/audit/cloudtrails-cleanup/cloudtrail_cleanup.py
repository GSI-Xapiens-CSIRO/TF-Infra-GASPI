#!/usr/bin/env python3
"""
CloudTrail Infrastructure Cleanup Script
Deletes Terraform-provisioned CloudTrail infrastructure while preserving CloudWatch log groups
and only removing the 'cloudtrail-to-kinesis' subscription filters.

Configuration sources (in priority order):
1. .env file
2. cloudtrails.txt file
3. Command line arguments
4. Environment variables
"""

import boto3
import json
import subprocess
import sys
import time
import os
import re
from typing import List, Dict, Any, Optional
from botocore.exceptions import ClientError, NoCredentialsError
from pathlib import Path

__version__ = "1.2.0"

class ConfigLoader:
    """Load configuration from various sources"""

    @staticmethod
    def load_env_file(env_file: str = ".env") -> Dict[str, str]:
        """Load environment variables from .env file"""
        config = {}
        env_path = Path(env_file)

        if not env_path.exists():
            print(f"⚠️  .env file not found: {env_file}")
            return config

        try:
            with open(env_path, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        # Remove quotes if present
                        value = value.strip('"\'')
                        config[key.strip()] = value

            print(f"✓ Loaded configuration from {env_file}")
            return config

        except Exception as e:
            print(f"❌ Error loading .env file: {str(e)}")
            return {}

    @staticmethod
    def load_cloudtrails_txt(file_path: str = "cloudtrails.txt") -> Dict[str, Any]:
        """Load configuration from cloudtrails.txt terraform output file"""
        config = {}
        file_path_obj = Path(file_path)

        if not file_path_obj.exists():
            print(f"⚠️  cloudtrails.txt file not found: {file_path}")
            return config

        try:
            with open(file_path_obj, 'r') as f:
                content = f.read()

            # Parse terraform output format
            lines = content.strip().split('\n')
            for line in lines:
                if '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip()

                    # Handle different value types
                    if value.startswith('"') and value.endswith('"'):
                        # String value
                        config[key] = value[1:-1]  # Remove quotes
                    elif value.startswith('[') and value.endswith(']'):
                        # List value
                        # Extract list items (handle multi-line lists)
                        list_content = value[1:-1]  # Remove brackets
                        if list_content.strip():
                            # Split by comma and clean up
                            items = []
                            for item in list_content.split(','):
                                item = item.strip().strip('"')
                                if item:
                                    items.append(item)
                            config[key] = items
                        else:
                            config[key] = []
                    elif value.startswith('{') and value.endswith('}'):
                        # Dict/object value - try to parse as JSON-like
                        try:
                            # Simple parsing for key-value pairs
                            obj_content = value[1:-1]  # Remove braces
                            obj_dict = {}
                            # This is a simplified parser - may need enhancement
                            config[key] = obj_content  # Store as string for now
                        except:
                            config[key] = value
                    elif value.lower() in ['true', 'false']:
                        # Boolean value
                        config[key] = value.lower() == 'true'
                    elif value.isdigit():
                        # Integer value
                        config[key] = int(value)
                    elif value == '<sensitive>':
                        # Sensitive value
                        config[key] = None
                    else:
                        # Default to string
                        config[key] = value

            print(f"✓ Loaded configuration from {file_path}")
            return config

        except Exception as e:
            print(f"❌ Error loading cloudtrails.txt: {str(e)}")
            return {}

    @staticmethod
    def parse_terraform_list(value: str) -> List[str]:
        """Parse terraform list format to Python list"""
        if not value.startswith('[') or not value.endswith(']'):
            return []

        # Remove brackets and split by comma
        content = value[1:-1]
        items = []

        # Handle multi-line format
        lines = content.split('\n')
        for line in lines:
            line = line.strip()
            if line.endswith(','):
                line = line[:-1]  # Remove trailing comma
            line = line.strip('"')  # Remove quotes
            if line:
                items.append(line)

        return items

    @classmethod
    def load_configuration(cls, env_file: str = ".env", cloudtrails_file: str = "cloudtrails.txt") -> Dict[str, Any]:
        """
        Load configuration from multiple sources with priority order:
        1. .env file
        2. cloudtrails.txt file
        3. Environment variables
        """
        config = {}

        # Load from cloudtrails.txt first (lower priority)
        cloudtrails_config = cls.load_cloudtrails_txt(cloudtrails_file)
        config.update(cloudtrails_config)

        # Load from .env file (higher priority)
        env_config = cls.load_env_file(env_file)
        config.update(env_config)

        # Load from environment variables (highest priority)
        env_vars = {
            'AWS_REGION': os.getenv('AWS_REGION'),
            'AWS_ACCOUNT_ID': os.getenv('AWS_ACCOUNT_ID'),
            'TERRAFORM_DIR': os.getenv('TERRAFORM_DIR'),
        }

        for key, value in env_vars.items():
            if value:
                config[key.lower()] = value

        # Parse special list formats from cloudtrails.txt
        if 'cloudwatch_log_groups_sbeacon' in config and isinstance(config['cloudwatch_log_groups_sbeacon'], str):
            config['cloudwatch_log_groups_sbeacon'] = cls.parse_terraform_list(config['cloudwatch_log_groups_sbeacon'])

        if 'cloudwatch_log_groups_svep' in config and isinstance(config['cloudwatch_log_groups_svep'], str):
            config['cloudwatch_log_groups_svep'] = cls.parse_terraform_list(config['cloudwatch_log_groups_svep'])

        return config


class CloudTrailInfrastructureCleanup:
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize the cleanup class with configuration

        Args:
            config: Configuration dictionary
        """
        self.config = config
        self.region = config.get('aws_region', config.get('AWS_REGION', 'ap-southeast-3'))
        self.account_id = config.get('aws_account_id', config.get('AWS_ACCOUNT_ID', '209479276142'))

        # Initialize AWS clients
        try:
            session = boto3.Session(region_name=self.region)
            self.cloudtrail = session.client('cloudtrail')
            self.logs = session.client('logs')
            self.kinesis = session.client('kinesis')
            self.firehose = session.client('firehose')
            self.opensearch = session.client('opensearch')
            self.lambda_client = session.client('lambda')
            self.s3 = session.client('s3')
            self.iam = session.client('iam')
            self.ssm = session.client('ssm')
            self.kms = session.client('kms')
            self.sns = session.client('sns')

            print(f"✓ AWS clients initialized successfully (Region: {self.region})")

        except NoCredentialsError:
            print("❌ AWS credentials not found. Please configure your credentials.")
            sys.exit(1)
        except Exception as e:
            print(f"❌ Error initializing AWS clients: {str(e)}")
            sys.exit(1)

    def unsubscribe_cloudwatch_filters(self) -> None:
        """Remove only the 'cloudtrail-to-kinesis' subscription filters from CloudWatch log groups"""
        print("\n🔄 Removing CloudWatch log group subscription filters...")

        # Get log groups from config
        sbeacon_groups = self.config.get('cloudwatch_log_groups_sbeacon', [])
        svep_groups = self.config.get('cloudwatch_log_groups_svep', [])
        all_log_groups = sbeacon_groups + svep_groups

        if not all_log_groups:
            print("⚠️  No CloudWatch log groups found in configuration")
            return

        removed_count = 0
        for log_group in all_log_groups:
            try:
                # Get existing subscription filters
                response = self.logs.describe_subscription_filters(
                    logGroupName=log_group
                )

                # Find and remove only the cloudtrail-to-kinesis filter
                for filter_info in response.get('subscriptionFilters', []):
                    filter_name = filter_info['filterName']

                    if any(keyword in filter_name.lower() for keyword in ['cloudtrail-to-kinesis', 'cloudtrail', 'kinesis']):
                        print(f"  📝 Removing subscription filter '{filter_name}' from {log_group}")

                        self.logs.delete_subscription_filter(
                            logGroupName=log_group,
                            filterName=filter_name
                        )
                        print(f"  ✓ Removed subscription filter from {log_group}")
                        removed_count += 1

            except ClientError as e:
                error_code = e.response['Error']['Code']
                if error_code == 'ResourceNotFoundException':
                    print(f"  ⚠️  Log group {log_group} not found, skipping...")
                else:
                    print(f"  ❌ Error processing {log_group}: {str(e)}")
            except Exception as e:
                print(f"  ❌ Unexpected error processing {log_group}: {str(e)}")

        print(f"✓ Removed subscription filters from {removed_count} log groups")

    def delete_opensearch_domain(self) -> None:
        """Delete OpenSearch domain"""
        domain_name = self.config.get('opensearch_domain_name', '')

        if not domain_name:
            print("⚠️  No OpenSearch domain name found in configuration")
            return

        print(f"\n🔄 Deleting OpenSearch domain: {domain_name}")

        try:
            # Check if domain exists
            self.opensearch.describe_domain(DomainName=domain_name)

            # Delete the domain
            response = self.opensearch.delete_domain(DomainName=domain_name)
            print(f"✓ OpenSearch domain deletion initiated: {domain_name}")
            print("⏳ Domain deletion can take 10-15 minutes to complete...")

        except ClientError as e:
            if e.response['Error']['Code'] == 'ResourceNotFoundException':
                print(f"⚠️  OpenSearch domain {domain_name} not found, skipping...")
            else:
                print(f"❌ Error deleting OpenSearch domain: {str(e)}")

    def delete_kinesis_resources(self) -> None:
        """Delete Kinesis Data Stream and Firehose"""
        stream_name = self.config.get('kinesis_firehose_stream_name', '')
        firehose_name = self.config.get('kinesis_firehose_name', '')

        print(f"\n🔄 Deleting Kinesis resources...")

        # Delete Kinesis Firehose
        if firehose_name:
            try:
                self.firehose.delete_delivery_stream(
                    DeliveryStreamName=firehose_name,
                    AllowForceDelete=True
                )
                print(f"✓ Kinesis Firehose deletion initiated: {firehose_name}")
            except ClientError as e:
                if e.response['Error']['Code'] == 'ResourceNotFoundException':
                    print(f"⚠️  Kinesis Firehose {firehose_name} not found, skipping...")
                else:
                    print(f"❌ Error deleting Kinesis Firehose: {str(e)}")
        else:
            print("⚠️  No Kinesis Firehose name found in configuration")

        # Delete Kinesis Data Stream
        if stream_name:
            try:
                self.kinesis.delete_stream(
                    StreamName=stream_name,
                    EnforceConsumerDeletion=True
                )
                print(f"✓ Kinesis Data Stream deletion initiated: {stream_name}")
            except ClientError as e:
                if e.response['Error']['Code'] == 'ResourceNotFoundException':
                    print(f"⚠️  Kinesis Data Stream {stream_name} not found, skipping...")
                else:
                    print(f"❌ Error deleting Kinesis Data Stream: {str(e)}")
        else:
            print("⚠️  No Kinesis Data Stream name found in configuration")

    def delete_lambda_function(self) -> None:
        """Delete Lambda function"""
        function_name = self.config.get('lambda_function_name', '')

        if not function_name:
            print("⚠️  No Lambda function name found in configuration")
            return

        print(f"\n🔄 Deleting Lambda function: {function_name}")

        try:
            self.lambda_client.delete_function(FunctionName=function_name)
            print(f"✓ Lambda function deleted: {function_name}")
        except ClientError as e:
            if e.response['Error']['Code'] == 'ResourceNotFoundException':
                print(f"⚠️  Lambda function {function_name} not found, skipping...")
            else:
                print(f"❌ Error deleting Lambda function: {str(e)}")

    def delete_cloudtrail(self) -> None:
        """Delete CloudTrail"""
        cloudtrail_arn = self.config.get('cloudtrail_arn', '')

        if not cloudtrail_arn:
            print("⚠️  No CloudTrail ARN found in configuration")
            return

        print(f"\n🔄 Deleting CloudTrail...")

        trail_name = cloudtrail_arn.split('/')[-1]

        try:
            # Stop logging first
            self.cloudtrail.stop_logging(Name=trail_name)
            print(f"✓ CloudTrail logging stopped: {trail_name}")

            # Delete the trail
            self.cloudtrail.delete_trail(Name=trail_name)
            print(f"✓ CloudTrail deleted: {trail_name}")

        except ClientError as e:
            if e.response['Error']['Code'] == 'TrailNotFoundException':
                print(f"⚠️  CloudTrail {trail_name} not found, skipping...")
            else:
                print(f"❌ Error deleting CloudTrail: {str(e)}")

    def delete_s3_bucket_objects(self) -> None:
        """Empty S3 bucket contents (required before bucket deletion)"""
        bucket_name = self.config.get('cloudtrail_bucket', '')

        if not bucket_name:
            print("⚠️  No S3 bucket name found in configuration")
            return

        print(f"\n🔄 Emptying S3 bucket: {bucket_name}")

        try:
            # Check if bucket exists
            self.s3.head_bucket(Bucket=bucket_name)

            # List and delete all objects
            paginator = self.s3.get_paginator('list_objects_v2')
            pages = paginator.paginate(Bucket=bucket_name)

            objects_to_delete = []
            for page in pages:
                if 'Contents' in page:
                    for obj in page['Contents']:
                        objects_to_delete.append({'Key': obj['Key']})

            if objects_to_delete:
                # Delete objects in batches of 1000
                for i in range(0, len(objects_to_delete), 1000):
                    batch = objects_to_delete[i:i+1000]
                    self.s3.delete_objects(
                        Bucket=bucket_name,
                        Delete={'Objects': batch}
                    )

                print(f"✓ Deleted {len(objects_to_delete)} objects from {bucket_name}")
            else:
                print(f"✓ Bucket {bucket_name} is already empty")

        except ClientError as e:
            if e.response['Error']['Code'] == '404':
                print(f"⚠️  S3 bucket {bucket_name} not found, skipping...")
            else:
                print(f"❌ Error emptying S3 bucket: {str(e)}")

    def delete_ssm_parameters(self) -> None:
        """Delete SSM parameters"""
        password_param = self.config.get('opensearch_password_parameter', '')

        if not password_param:
            print("⚠️  No SSM parameters found in configuration")
            return

        print(f"\n🔄 Deleting SSM parameters...")

        try:
            self.ssm.delete_parameter(Name=password_param)
            print(f"✓ SSM parameter deleted: {password_param}")
        except ClientError as e:
            if e.response['Error']['Code'] == 'ParameterNotFound':
                print(f"⚠️  SSM parameter {password_param} not found, skipping...")
            else:
                print(f"❌ Error deleting SSM parameter {password_param}: {str(e)}")

    def run_terraform_destroy(self, terraform_dir: str) -> None:
        """Run terraform destroy command"""
        print(f"\n🔄 Running terraform destroy in {terraform_dir}...")

        try:
            # Check if terraform files exist
            tf_files = list(Path(terraform_dir).glob("*.tf"))
            if not tf_files:
                print(f"⚠️  No terraform files found in {terraform_dir}, skipping terraform destroy")
                return

            # Run terraform destroy
            result = subprocess.run(
                ["terraform", "destroy", "-auto-approve"],
                cwd=terraform_dir,
                capture_output=True,
                text=True,
                timeout=1800  # 30 minutes timeout
            )

            if result.returncode == 0:
                print("✓ Terraform destroy completed successfully")
                if result.stdout:
                    print("Terraform output:", result.stdout[-500:])  # Last 500 chars
            else:
                print(f"❌ Terraform destroy failed with return code {result.returncode}")
                print("STDOUT:", result.stdout[-500:])  # Last 500 chars
                print("STDERR:", result.stderr[-500:])  # Last 500 chars

        except subprocess.TimeoutExpired:
            print("❌ Terraform destroy timed out after 30 minutes")
        except FileNotFoundError:
            print("❌ Terraform not found. Please install Terraform or run this script from the terraform directory")
        except Exception as e:
            print(f"❌ Error running terraform destroy: {str(e)}")

    def cleanup_infrastructure(self, terraform_dir: str = ".", dry_run: bool = False) -> None:
        """
        Main cleanup method that orchestrates the deletion process

        Args:
            terraform_dir: Path to terraform directory
            dry_run: If True, only show what would be deleted
        """
        print("🚀 Starting CloudTrail Infrastructure Cleanup...")
        print("=" * 60)

        if dry_run:
            print("🔍 DRY RUN MODE - No resources will be deleted")
            self._show_cleanup_plan()
            return

        try:
            # Step 1: Remove subscription filters from CloudWatch log groups
            self.unsubscribe_cloudwatch_filters()

            # Step 2: Delete Lambda function (to remove dependencies)
            self.delete_lambda_function()

            # Step 3: Delete Kinesis resources
            self.delete_kinesis_resources()

            # Step 4: Delete CloudTrail
            self.delete_cloudtrail()

            # Step 5: Empty S3 bucket (required before deletion)
            self.delete_s3_bucket_objects()

            # Step 6: Delete SSM parameters
            self.delete_ssm_parameters()

            # Step 7: Delete OpenSearch domain (this takes the longest)
            self.delete_opensearch_domain()

            print("\n⏳ Waiting for resources to be deleted before running Terraform destroy...")
            print("   (OpenSearch domain deletion can take 10-15 minutes)")
            time.sleep(60)  # Wait 1 minute before proceeding

            # Step 8: Run terraform destroy to clean up remaining resources
            self.run_terraform_destroy(terraform_dir)

            self._print_cleanup_summary()

        except KeyboardInterrupt:
            print("\n⚠️  Cleanup interrupted by user")
            sys.exit(1)
        except Exception as e:
            print(f"\n❌ Unexpected error during cleanup: {str(e)}")
            sys.exit(1)

    def _show_cleanup_plan(self) -> None:
        """Show what would be cleaned up in dry-run mode"""
        print("\n📋 Resources that would be processed:")

        sbeacon_groups = self.config.get('cloudwatch_log_groups_sbeacon', [])
        svep_groups = self.config.get('cloudwatch_log_groups_svep', [])
        total_log_groups = len(sbeacon_groups) + len(svep_groups)

        print(f"  🔹 CloudWatch Log Groups (subscription filters only): {total_log_groups}")
        print(f"    - sBeacon groups: {len(sbeacon_groups)}")
        print(f"    - sVEP groups: {len(svep_groups)}")

        resources = [
            ("OpenSearch Domain", self.config.get('opensearch_domain_name', 'N/A')),
            ("Kinesis Stream", self.config.get('kinesis_firehose_stream_name', 'N/A')),
            ("Kinesis Firehose", self.config.get('kinesis_firehose_name', 'N/A')),
            ("Lambda Function", self.config.get('lambda_function_name', 'N/A')),
            ("CloudTrail", self.config.get('cloudtrail_arn', 'N/A').split('/')[-1] if self.config.get('cloudtrail_arn') else 'N/A'),
            ("S3 Bucket", self.config.get('cloudtrail_bucket', 'N/A')),
            ("SSM Parameter", self.config.get('opensearch_password_parameter', 'N/A')),
        ]

        for resource_type, resource_name in resources:
            status = "✓" if resource_name != 'N/A' else "❌"
            print(f"  {status} {resource_type}: {resource_name}")

        print(f"\n🔧 Configuration loaded from:")
        print(f"  • Region: {self.region}")
        print(f"  • Account ID: {self.account_id}")

    def _print_cleanup_summary(self) -> None:
        """Print cleanup completion summary"""
        print("\n" + "=" * 80)
        print("🎉 CloudTrail Infrastructure Cleanup completed!")

        sbeacon_groups = self.config.get('cloudwatch_log_groups_sbeacon', [])
        svep_groups = self.config.get('cloudwatch_log_groups_svep', [])
        total_log_groups = len(sbeacon_groups) + len(svep_groups)

        print("\n📝 Summary:")
        print(f"  • Unsubscribed 'cloudtrail-to-kinesis' filters from {total_log_groups} log groups")
        print(f"  • Deleted Lambda function: {self.config.get('lambda_function_name', 'N/A')}")
        print(f"  • Deleted Kinesis resources")
        print(f"  • Deleted CloudTrail: {self.config.get('cloudtrail_arn', 'N/A').split('/')[-1] if self.config.get('cloudtrail_arn') else 'N/A'}")
        print(f"  • Emptied S3 bucket: {self.config.get('cloudtrail_bucket', 'N/A')}")
        print(f"  • Deleted OpenSearch domain: {self.config.get('opensearch_domain_name', 'N/A')}")
        print(f"  • Executed terraform destroy")
        print("\n⚠️  Note: CloudWatch log groups were preserved as requested")


def main():
    """Main function"""
    import argparse

    parser = argparse.ArgumentParser(
        description="Clean up CloudTrail infrastructure using configuration from .env or cloudtrails.txt"
    )
    parser.add_argument(
        "--terraform-dir",
        help="Path to terraform directory (default: from config or current directory)"
    )
    parser.add_argument(
        "--env-file",
        default=".env",
        help="Path to .env file (default: .env)"
    )
    parser.add_argument(
        "--cloudtrails-file",
        default="cloudtrails.txt",
        help="Path to cloudtrails.txt file (default: cloudtrails.txt)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be deleted without actually deleting"
    )
    parser.add_argument(
        "--show-config",
        action="store_true",
        help="Show loaded configuration and exit"
    )

    args = parser.parse_args()

    # Load configuration
    print("🔧 Loading configuration...")
    config = ConfigLoader.load_configuration(args.env_file, args.cloudtrails_file)

    if not config:
        print("❌ No configuration found. Please provide .env file or cloudtrails.txt")
        sys.exit(1)

    # Override terraform directory if provided
    terraform_dir = args.terraform_dir or config.get('terraform_dir', config.get('TERRAFORM_DIR', '.'))

    if args.show_config:
        print("\n📋 Loaded Configuration:")
        print("-" * 40)
        sensitive_keys = ['password', 'secret', 'key']
        for key, value in config.items():
            if any(sensitive in key.lower() for sensitive in sensitive_keys):
                print(f"{key}: <HIDDEN>")
            elif isinstance(value, list) and len(value) > 3:
                print(f"{key}: [{len(value)} items] {value[:3]}...")
            else:
                print(f"{key}: {value}")
        print(f"\nTerraform directory: {terraform_dir}")
        return

    if args.dry_run:
        print("🔍 DRY RUN MODE - No resources will be deleted")
        print("=" * 60)

    # Initialize cleanup class
    cleanup = CloudTrailInfrastructureCleanup(config)

    # Run cleanup
    cleanup.cleanup_infrastructure(terraform_dir, args.dry_run)


if __name__ == "__main__":
    main()