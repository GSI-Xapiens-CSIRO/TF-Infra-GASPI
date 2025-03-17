#!/usr/bin/env python3
"""
AWS Resource Cleanup Script for sBeacon and sVEP Services
Author: DevOps Team
Version: 4.0.0 (2025-01-03)

This script provides automated cleanup of AWS resources related to sBeacon and sVEP services.
It includes cleanup functionality for CloudFormation stacks, Lambda functions, DynamoDB tables,
IAM roles and policies, and ECR repositories.
"""

import boto3
import logging
import os
import time
import json
import sys
from botocore.exceptions import ClientError, WaiterError
from datetime import datetime
from typing import List, Dict, Optional, Any, Callable
from functools import wraps
from dotenv import load_dotenv

__version__ = "4.0.0"
__author__ = "DevOps Team"
__created__ = "2025-01-03"

# Load environment variables
load_dotenv()

class Version:
    """Version information and metadata"""
    MAJOR = 4
    MINOR = 0
    PATCH = 0
    BUILD = "2025.01.03"

    @classmethod
    def get_version_string(cls) -> str:
        """Returns formatted version string"""
        return f"{cls.MAJOR}.{cls.MINOR}.{cls.PATCH} ({cls.BUILD})"

    @classmethod
    def display_version(cls) -> None:
        """Displays version information"""
        print(f"\nAWS Resource Cleanup Tool v{cls.get_version_string()}")
        print("Copyright (c) 2025 DevOps Team\n")

# Get AWS credentials from environment
AWS_ACCESS_KEY = os.getenv('AWS_ACCESS_KEY')
AWS_SECRET_KEY = os.getenv('AWS_SECRET_KEY')
AWS_REGION = os.getenv('AWS_REGION')

if not all([AWS_ACCESS_KEY, AWS_SECRET_KEY, AWS_REGION]):
    print("Error: Missing required AWS credentials in .env file")
    print("Please create a .env file with:")
    print("AWS_ACCESS_KEY=your_access_key")
    print("AWS_SECRET_KEY=your_secret_key")
    print("AWS_REGION=your_region")
    sys.exit(1)

def log_execution_time(func: Callable) -> Callable:
    """Decorator to log function execution time and status"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        logger = logging.getLogger('AWSCleanup')
        start_time = time.time()

        try:
            logger.info(f"Starting {func.__name__}")
            result = func(*args, **kwargs)
            execution_time = time.time() - start_time
            logger.info(f"Completed {func.__name__} in {execution_time:.2f} seconds")
            return result

        except Exception as e:
            execution_time = time.time() - start_time
            logger.error(f"Failed {func.__name__} after {execution_time:.2f} seconds: {str(e)}")
            raise

    return wrapper

class LogFormatter(logging.Formatter):
    """Custom log formatter with color support"""

    def __init__(self):
        super().__init__()
        self.colors = {
            'DEBUG': '\033[0;36m',    # Cyan
            'INFO': '\033[0;32m',     # Green
            'WARNING': '\033[0;33m',  # Yellow
            'ERROR': '\033[0;31m',    # Red
            'CRITICAL': '\033[0;35m', # Purple
            'RESET': '\033[0m'        # Reset
        }

    def format(self, record):
        color = self.colors.get(record.levelname, self.colors['RESET'])
        reset = self.colors['RESET']
        timestamp = datetime.fromtimestamp(record.created).strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]
        message = f"{color}[{timestamp}] [{record.levelname}] {record.getMessage()}{reset}"

        if record.exc_info:
            message += f"\n{self.formatException(record.exc_info)}"
        return message

def setup_logging() -> logging.Logger:
    """Configure logging with console and file output"""
    logger = logging.getLogger('AWSCleanup')
    logger.setLevel(logging.INFO)

    # Create logs directory if it doesn't exist
    os.makedirs('logs', exist_ok=True)

    # Console handler
    console = logging.StreamHandler()
    console.setFormatter(LogFormatter())
    logger.addHandler(console)

    # File handler
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_handler = logging.FileHandler(f'logs/cleanup_{timestamp}.log')
    file_handler.setFormatter(LogFormatter())
    logger.addHandler(file_handler)

    return logger

class AWSResourceCleaner:
    """AWS resource cleanup manager"""

    def __init__(self):
        self.logger = setup_logging()
        self.session = boto3.Session(
            aws_access_key_id=AWS_ACCESS_KEY,
            aws_secret_access_key=AWS_SECRET_KEY,
            region_name=AWS_REGION
        )
        self._init_clients()
        self.account_id = self.sts.get_caller_identity()['Account']

    def _init_clients(self):
        """Initialize AWS service clients"""
        services = {
            'iam': 'iam',
            'lambda_client': 'lambda',
            'dynamodb': 'dynamodb',
            'cloudwatch': 'cloudwatch',
            'logs': 'logs',
            'glue': 'glue',
            'athena': 'athena',
            'ses': 'ses',
            'cloudfront': 'cloudfront',
            'cloudformation': 'cloudformation',
            'ecr': 'ecr',
            'sts': 'sts'
        }

        for attr, service in services.items():
            setattr(self, attr, self.session.client(service))

    def wait_for_deletion(self, waiter_name: str, client: Any, **kwargs):
        """Wait for resource deletion with timeout"""
        try:
            waiter = client.get_waiter(waiter_name)
            waiter.wait(
                **kwargs,
                WaiterConfig={
                    'Delay': 5,
                    'MaxAttempts': 40
                }
            )
        except WaiterError as e:
            self.logger.error(f"Timeout waiting for {waiter_name}: {str(e)}")
            raise

    @log_execution_time
    def clean_cloudformation_stacks(self):
        """Delete CloudFormation stacks"""
        stacks = [
            'sbeacon-terms-index-stack',
            'sbeacon-terms-stack'
        ]

        for stack in stacks:
            try:
                self.cloudformation.delete_stack(StackName=stack)
                self.logger.info(f"Deleting stack {stack}...")
                self.wait_for_deletion('stack_delete_complete', self.cloudformation, StackName=stack)
                self.logger.info(f"Successfully deleted stack {stack}")
            except ClientError as e:
                if 'does not exist' not in str(e):
                    self.logger.error(f"Error deleting stack {stack}: {str(e)}")

    @log_execution_time
    def clean_lambda_functions(self):
        """Delete Lambda functions and their log groups"""
        functions = [
            'admin', 'dataPortal', 'getAnalyses', 'getBiosamples', 'getConfiguration',
            'getDatasets', 'getEntryTypes', 'getFilteringTerms', 'getGenomicVariants',
            'getIndividuals', 'getInfo', 'getMap', 'getRuns', 'indexer',
            'logEmailDelivery', 'performQuery', 'splitQuery', 'submitDataset'
        ]

        for func in functions:
            full_name = f"sbeacon-backend-{func}"
            try:
                # Delete function
                self.lambda_client.delete_function(FunctionName=full_name)
                self.logger.info(f"Deleted Lambda function {full_name}")

                # Delete log group
                log_group = f"/aws/lambda/{full_name}"
                self.logs.delete_log_group(logGroupName=log_group)
                self.logger.info(f"Deleted log group {log_group}")
            except ClientError as e:
                if 'ResourceNotFoundException' not in str(e):
                    self.logger.error(f"Error cleaning Lambda {full_name}: {str(e)}")

    @log_execution_time
    def clean_dynamodb_tables(self):
        """Delete DynamoDB tables"""
        tables = [
            'sbeacon-Ontologies',
            'sbeacon-Descendants',
            'sbeacon-Anscestors',
            'sbeacon-dataportal-projects',
            'sbeacon-dataportal-project-users',
            'sbeacon-dataportal-juptyer-notebooks',
            'sbeacon-vcfs',
            'sbeacon-dataportal-users-quota'
        ]

        for table in tables:
            try:
                self.dynamodb.delete_table(TableName=table)
                self.wait_for_deletion('table_not_exists', self.dynamodb, TableName=table)
                self.logger.info(f"Deleted DynamoDB table {table}")
            except ClientError as e:
                if e.response['Error']['Code'] != 'ResourceNotFoundException':
                    self.logger.error(f"Error deleting table {table}: {str(e)}")

    @log_execution_time
    def clean_iam_roles(self):
        """Delete IAM roles and their policies"""
        roles = [
            'gaspi_authenticated',
            'gaspi_unauthenticated',
            'gaspi-admin-group-role',
            'glue_role',
            'sbeacon_backend_sagemaker_jupyter_instance_role',
            'sbeacon-backend-admin',
            'sbeacon-backend-dataPortal',
            'sbeacon-backend-getAnalyses',
            'sbeacon-backend-getBiosamples',
            'sbeacon-backend-getConfiguration',
            'sbeacon-backend-getDatasets',
            'sbeacon-backend-getEntryTypes',
            'sbeacon-backend-getFilteringTerms',
            'sbeacon-backend-getGenomicVariants',
            'sbeacon-backend-getIndividuals',
            'sbeacon-backend-getInfo',
            'sbeacon-backend-getMap',
            'sbeacon-backend-getProjects',
            'sbeacon-backend-getRuns',
            'sbeacon-backend-indexer',
            'sbeacon-backend-logEmailDelivery',
            'sbeacon-backend-performQuery',
            'sbeacon-backend-splitQuery',
            'sbeacon-backend-submitDataset',
            'sbeacon-backend-updateFiles'
        ]

        for role in roles:
            try:
                # Detach managed policies
                paginator = self.iam.get_paginator('list_attached_role_policies')
                for page in paginator.paginate(RoleName=role):
                    for policy in page['AttachedPolicies']:
                        self.iam.detach_role_policy(
                            RoleName=role,
                            PolicyArn=policy['PolicyArn']
                        )
                        self.logger.info(f"Detached policy {policy['PolicyArn']} from role {role}")

                # Delete inline policies
                paginator = self.iam.get_paginator('list_role_policies')
                for page in paginator.paginate(RoleName=role):
                    for policy_name in page['PolicyNames']:
                        self.iam.delete_role_policy(
                            RoleName=role,
                            PolicyName=policy_name
                        )
                        self.logger.info(f"Deleted inline policy {policy_name} from role {role}")

                # Delete role
                time.sleep(2)  # Wait for policy detachment
                self.iam.delete_role(RoleName=role)
                self.logger.info(f"Deleted role {role}")

            except ClientError as e:
                if e.response['Error']['Code'] != 'NoSuchEntity':
                    self.logger.error(f"Error cleaning role {role}: {str(e)}")

    @log_execution_time
    def clean_iam_policies(self):
        """Delete IAM policies"""
        try:
            paginator = self.iam.get_paginator('list_policies')
            for page in paginator.paginate(Scope='Local'):
                for policy in page['Policies']:
                    if ('sbeacon-backend' in policy['PolicyName'] or
                        'gaspi' in policy['PolicyName'] or
                        'glue' in policy['PolicyName']):
                        try:
                            # Delete non-default versions first
                            versions = self.iam.list_policy_versions(PolicyArn=policy['Arn'])
                            for version in versions['Versions']:
                                if not version['IsDefaultVersion']:
                                    self.iam.delete_policy_version(
                                        PolicyArn=policy['Arn'],
                                        VersionId=version['VersionId']
                                    )

                            # Delete policy
                            self.iam.delete_policy(PolicyArn=policy['Arn'])
                            self.logger.info(f"Deleted policy {policy['PolicyName']}")

                        except ClientError as e:
                            if e.response['Error']['Code'] != 'NoSuchEntity':
                                self.logger.error(f"Error deleting policy {policy['PolicyName']}: {str(e)}")

        except ClientError as e:
            self.logger.error(f"Error listing policies: {str(e)}")

    @log_execution_time
    def clean_ecr_repositories(self):
        """Delete ECR repositories"""
        repos = ['svep-pluginconsequence-lambda-containers']

        for repo in repos:
            try:
                self.ecr.delete_repository(
                    repositoryName=repo,
                    force=True
                )
                self.logger.info(f"Deleted ECR repository {repo}")
            except ClientError as e:
                if e.response['Error']['Code'] != 'RepositoryNotFoundException':
                    self.logger.error(f"Error deleting ECR repository {repo}: {str(e)}")

    @log_execution_time
    def cleanup_all(self):
        """Execute complete cleanup process"""
        self.logger.info("Starting AWS resource cleanup")

        cleanup_steps = [
            (self.clean_cloudformation_stacks, "CloudFormation stacks"),
            (self.clean_lambda_functions, "Lambda functions"),
            (self.clean_dynamodb_tables, "DynamoDB tables"),
            (self.clean_ecr_repositories, "ECR repositories"),
            (self.clean_iam_policies, "IAM policies"),
            (self.clean_iam_roles, "IAM roles")
        ]

        for cleanup_func, resource_type in cleanup_steps:
            try:
                self.logger.info(f"Cleaning up {resource_type}...")
                cleanup_func()
                self.logger.info(f"Completed cleanup of {resource_type}")
            except Exception as e:
                self.logger.error(f"Error during cleanup of {resource_type}: {str(e)}")
                continue

        self.logger.info("Cleanup process completed")

def main():
    """Main entry point"""
    try:
        Version.display_version()

        print("WARNING: This script will delete AWS resources!")
        print(f"Region: {AWS_REGION}")
        print(f"Script Version: {Version.get_version_string()}")
        response = input("\nType 'YES' to proceed: ")

        if response.strip().upper() != 'YES':
            print("Cleanup cancelled")
            return

        cleaner = AWSResourceCleaner()
        cleaner.cleanup_all()

    except KeyboardInterrupt:
        print("\nCleanup interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\nError during cleanup: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()