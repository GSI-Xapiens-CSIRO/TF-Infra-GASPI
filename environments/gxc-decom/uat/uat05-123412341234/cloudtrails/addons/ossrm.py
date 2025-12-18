#!/usr/bin/env python3

import os
import json
import argparse
import boto3
import requests
from requests_aws4auth import AWS4Auth
from requests.auth import HTTPBasicAuth
from botocore.exceptions import ClientError
from urllib3.exceptions import InsecureRequestWarning
import urllib3

# Suppress only the single warning from urllib3 needed.
urllib3.disable_warnings(InsecureRequestWarning)

__version__ = "1.0.5"

# ASCII Art Logo
LOGO = r"""
  ____    _____ _____ ____  __  __
 / __ \  / ___// ___// __ \/  |/  /
/ / / /  \__ \ \__ \/ /_/ / /|_/ /
\ \/ /  ___/ /___/ / _, _/ /  / /
 \__/  /____//____/_/ |_/_/  /_/

OpenSearch Snapshot Repository Manager v{}
"""

def print_header():
    """Print the application header with version"""
    global __version__
    print(LOGO.format(__version__))
    print("=" * 80)
    print()

def assume_role(role_arn, region):
    """Assume an IAM role and return credentials"""
    try:
        sts_client = boto3.client('sts', region_name=region)
        assumed_role = sts_client.assume_role(
            RoleArn=role_arn,
            RoleSessionName='OpenSearchSnapshotSession'
        )
        credentials = assumed_role['Credentials']
        return credentials
    except Exception as e:
        print(f"Error assuming role: {str(e)}")
        raise

def get_aws_auth(region, credentials=None):
    """Get AWS authentication credentials"""
    try:
        if credentials:
            return AWS4Auth(
                credentials['AccessKeyId'],
                credentials['SecretAccessKey'],
                region,
                'es',
                session_token=credentials['SessionToken']
            )

        session = boto3.Session()
        credentials = session.get_credentials()

        if not credentials:
            raise Exception("No AWS credentials found")

        return AWS4Auth(
            credentials.access_key,
            credentials.secret_key,
            region,
            'es',
            session_token=credentials.token
        )
    except Exception as e:
        print(f"Error getting AWS credentials: {str(e)}")
        raise

def verify_bucket_access(bucket_name, region):
    """Verify S3 bucket access and existence"""
    try:
        s3 = boto3.client('s3', region_name=region)
        s3.head_bucket(Bucket=bucket_name)
        print(f"✓ Successfully verified access to bucket: {bucket_name}")
        return True
    except Exception as e:
        print(f"❌ Error accessing bucket {bucket_name}: {str(e)}")
        return False

def register_snapshot_repository(
    domain_endpoint,
    region,
    bucket_name,
    role_arn,
    repository_name="genomic-snapshot",
    base_path="snapshots/daily",
    username=None,
    password=None,
    verify_ssl=True,
    master_role_arn=None
):
    """Register an S3 snapshot repository with OpenSearch"""

    # First verify bucket access
    if not verify_bucket_access(bucket_name, region):
        raise Exception(f"Unable to access bucket {bucket_name}")

    # Remove https:// if present
    if domain_endpoint.startswith("https://"):
        domain_endpoint = domain_endpoint[8:]

    # Construct the repository registration URL
    url = f"https://{domain_endpoint}/_snapshot/{repository_name}"

    # Set up authentication
    auth = None
    if username and password:
        auth = HTTPBasicAuth(username, password)
        print("Using basic authentication")
    elif master_role_arn:
        print(f"Assuming role: {master_role_arn}")
        credentials = assume_role(master_role_arn, region)
        auth = get_aws_auth(region, credentials)
        print("Using assumed role authentication")
    else:
        auth = get_aws_auth(region)
        print("Using AWS authentication")

    # Repository configuration
    repository_config = {
        "type": "s3",
        "settings": {
            "bucket": bucket_name,
            "base_path": base_path,
            "region": region,
            "role_arn": role_arn,
            "server_side_encryption": True,
            "buffer_size": "100mb",
            "chunk_size": "100mb",
            "compress": True,
            "max_restore_bytes_per_sec": "100mb",
            "max_snapshot_bytes_per_sec": "100mb",
            "readonly": False
        }
    }

    headers = {
        "Content-Type": "application/json",
        "User-Agent": f"OpenSearchSnapshotManager/{__version__}"
    }

    try:
        # Register repository
        url = f"https://{domain_endpoint}/_snapshot/{repository_name}"
        print(f"\nRegistering repository '{repository_name}'...")
        print(f"Configuration:\n{json.dumps(repository_config, indent=2)}")

        response = requests.put(
            url,
            auth=auth,
            json=repository_config,
            headers=headers,
            verify=verify_ssl,
            timeout=30
        )

        response.raise_for_status()
        print(f"✓ Successfully registered repository '{repository_name}'")
        print(f"Response: {json.dumps(response.json(), indent=2)}")

        # Verify repository
        print(f"\nVerifying repository '{repository_name}'...")
        verify_url = f"https://{domain_endpoint}/_snapshot/{repository_name}/_verify"
        verify_response = requests.post(
            verify_url,
            auth=auth,
            headers=headers,
            verify=verify_ssl,
            timeout=30
        )

        verify_response.raise_for_status()
        print(f"✓ Repository verification successful")
        print(f"Verification response: {json.dumps(verify_response.json(), indent=2)}")

    except requests.exceptions.RequestException as e:
        print(f"❌ Error registering repository: {str(e)}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Error details: {e.response.text}")
        raise

def main():
    print_header()
    parser = argparse.ArgumentParser(
        description='Register OpenSearch snapshot repository',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument('--endpoint', required=True, help='OpenSearch domain endpoint')
    parser.add_argument('--region', required=True, help='AWS region')
    parser.add_argument('--bucket', required=True, help='S3 bucket name')
    parser.add_argument('--role-arn', required=True, help='IAM role ARN')
    parser.add_argument('--repository', default='genomic-snapshot', help='Repository name')
    parser.add_argument('--base-path', default='snapshots/daily', help='Base path in S3 bucket')
    parser.add_argument('--username', help='OpenSearch username')
    parser.add_argument('--password', help='OpenSearch password')
    parser.add_argument('--master-role-arn', help='Master role ARN to assume')
    parser.add_argument('--no-verify-ssl', action='store_true', help='Disable SSL verification')
    parser.add_argument('--version', action='version', version=f'%(prog)s {__version__}')

    args = parser.parse_args()

    try:
        register_snapshot_repository(
            domain_endpoint=args.endpoint,
            region=args.region,
            bucket_name=args.bucket,
            role_arn=args.role_arn,
            repository_name=args.repository,
            base_path=args.base_path,
            username=args.username,
            password=args.password,
            verify_ssl=not args.no_verify_ssl,
            master_role_arn=args.master_role_arn
        )
        print("\n✓ Operation completed successfully")
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        exit(1)

if __name__ == "__main__":
    main()