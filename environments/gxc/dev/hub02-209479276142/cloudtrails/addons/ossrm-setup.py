#!/usr/bin/env python3

import argparse
import json
import requests
from requests.auth import HTTPBasicAuth
from urllib3.exceptions import InsecureRequestWarning
import urllib3

urllib3.disable_warnings(InsecureRequestWarning)

def setup_security_config(endpoint, username, password, role_arn, verify_ssl=True):
    """Configure OpenSearch security settings"""

    # Remove https:// if present
    if endpoint.startswith("https://"):
        endpoint = endpoint[8:]

    base_url = f"https://{endpoint}"
    auth = HTTPBasicAuth(username, password)
    headers = {"Content-Type": "application/json"}

    # Create custom role for snapshot management
    custom_role_name = "snapshot_manager"
    role_url = f"{base_url}/_plugins/_security/api/roles/{custom_role_name}"
    role_data = {
        "cluster_permissions": [
            "cluster:admin/snapshot/*",
            "cluster:admin/repository/*",
            "cluster_monitor",
            "cluster:admin/opendistro/snapshots/*",
            "cluster:admin/repository/*"
        ],
        "index_permissions": [{
            "index_patterns": ["*"],
            "allowed_actions": [
                "indices:admin/create",
                "indices:admin/mapping/put",
                "indices:data/write/bulk",
                "indices:data/write/index",
                "indices:admin/close",
                "indices:admin/open",
                "indices_monitor"
            ]
        }],
        "tenant_permissions": [{
            "tenant_patterns": ["global_tenant"],
            "allowed_actions": ["kibana_all_read"]
        }]
    }

    # Role mapping data
    role_mapping_url = f"{base_url}/_plugins/_security/api/rolesmapping/{custom_role_name}"
    role_mapping_data = {
        "backend_roles": [role_arn],
        "hosts": [],
        "users": [username]
    }

    try:
        # Create/Update role
        print(f"Creating/Updating role '{custom_role_name}'...")
        response = requests.put(
            role_url,
            auth=auth,
            headers=headers,
            json=role_data,
            verify=verify_ssl
        )
        response.raise_for_status()
        print(f"✓ Role '{custom_role_name}' configured successfully")
        print(f"Role configuration response: {response.json()}")

        # Create/Update role mapping
        print(f"\nConfiguring role mapping for '{custom_role_name}'...")
        response = requests.put(
            role_mapping_url,
            auth=auth,
            headers=headers,
            json=role_mapping_data,
            verify=verify_ssl
        )
        response.raise_for_status()
        print("✓ Role mapping configured successfully")
        print(f"Role mapping response: {response.json()}")

        # Verify configuration
        print("\nVerifying configuration...")
        verify_url = f"{base_url}/_plugins/_security/api/roles/{custom_role_name}"
        response = requests.get(
            verify_url,
            auth=auth,
            headers=headers,
            verify=verify_ssl
        )
        response.raise_for_status()
        print("✓ Configuration verification successful")
        print(f"Current role configuration:\n{json.dumps(response.json(), indent=2)}")

    except requests.exceptions.RequestException as e:
        print(f"❌ Error configuring security: {str(e)}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Error details: {e.response.text}")
        raise

def main():
    parser = argparse.ArgumentParser(description='Setup OpenSearch security configuration')
    parser.add_argument('--endpoint', required=True, help='OpenSearch domain endpoint')
    parser.add_argument('--username', required=True, help='OpenSearch admin username')
    parser.add_argument('--password', required=True, help='OpenSearch admin password')
    parser.add_argument('--role-arn', required=True, help='IAM role ARN to grant permissions')
    parser.add_argument('--no-verify-ssl', action='store_true', help='Disable SSL verification')

    args = parser.parse_args()

    try:
        setup_security_config(
            args.endpoint,
            args.username,
            args.password,
            args.role_arn,
            verify_ssl=not args.no_verify_ssl
        )
        print("\n✓ Security configuration completed successfully")
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        exit(1)

if __name__ == "__main__":
    main()