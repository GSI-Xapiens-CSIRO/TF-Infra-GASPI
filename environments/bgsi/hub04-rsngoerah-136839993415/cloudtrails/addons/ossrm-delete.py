#!/usr/bin/env python3

import argparse
import requests
from requests.auth import HTTPBasicAuth
from urllib3.exceptions import InsecureRequestWarning
import urllib3
import json

urllib3.disable_warnings(InsecureRequestWarning)

def delete_snapshot_repository(
    domain_endpoint,
    repository_name,
    username=None,
    password=None,
    verify_ssl=True
):
    """Delete a snapshot repository from OpenSearch"""

    # Remove https:// if present
    if domain_endpoint.startswith("https://"):
        domain_endpoint = domain_endpoint[8:]

    # Setup authentication
    auth = HTTPBasicAuth(username, password) if username and password else None

    # Construct URL
    url = f"https://{domain_endpoint}/_snapshot/{repository_name}"

    headers = {
        "Content-Type": "application/json"
    }

    try:
        # First get the repository to check if it exists
        print(f"Checking if repository '{repository_name}' exists...")
        response = requests.get(
            url,
            auth=auth,
            headers=headers,
            verify=verify_ssl,
            timeout=30
        )

        if response.status_code == 404:
            print(f"Repository '{repository_name}' does not exist. Nothing to delete.")
            return True

        # Delete the repository
        print(f"Deleting repository '{repository_name}'...")
        response = requests.delete(
            url,
            auth=auth,
            headers=headers,
            verify=verify_ssl,
            timeout=30
        )

        response.raise_for_status()
        print(f"✓ Successfully deleted repository '{repository_name}'")
        if hasattr(response, 'json'):
            try:
                print(f"Response: {json.dumps(response.json(), indent=2)}")
            except:
                print(f"Response status: {response.status_code}")

        return True

    except requests.exceptions.RequestException as e:
        print(f"❌ Error deleting repository: {str(e)}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Error details: {e.response.text}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Delete OpenSearch snapshot repository')
    parser.add_argument('--endpoint', required=True, help='OpenSearch domain endpoint')
    parser.add_argument('--repository', required=True, help='Repository name to delete')
    parser.add_argument('--username', help='OpenSearch username')
    parser.add_argument('--password', help='OpenSearch password')
    parser.add_argument('--no-verify-ssl', action='store_true', help='Disable SSL verification')

    args = parser.parse_args()

    try:
        success = delete_snapshot_repository(
            domain_endpoint=args.endpoint,
            repository_name=args.repository,
            username=args.username,
            password=args.password,
            verify_ssl=not args.no_verify_ssl
        )

        if success:
            print("\n✓ Operation completed successfully")
        else:
            print("\n❌ Failed to delete repository")
            exit(1)

    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        exit(1)

if __name__ == "__main__":
    main()