# test_lambda.py
import json
import base64
import gzip
from transform_cloudtrail import handler as transform_handler
from create_index_mapping import handler as mapping_handler

def create_test_cloudtrail_event():
    """Create a sample CloudTrail event for testing"""
    cloudtrail_event = {
        "eventVersion": "1.0",
        "userIdentity": {
            "type": "IAMUser",
            "principalId": "EXAMPLE",
            "arn": "arn:aws:iam::123456789012:user/test",
            "accountId": "123456789012",
            "userName": "test-user"
        },
        "eventTime": "2024-01-01T00:00:00Z",
        "eventSource": "sbeacon.amazonaws.com",
        "eventName": "GetDatasets",
        "awsRegion": "ap-southeast-3",
        "sourceIPAddress": "192.0.2.1",
        "userAgent": "console.amazonaws.com",
        "requestParameters": {
            "logGroupName": "/aws/lambda/test",
            "logStreamName": "2024/01/01/test",
            "requestContext": {
                "authorizer": {
                    "claims": {
                        "cognito:username": "test-user",
                        "email": "test@example.com",
                        "cognito:groups": "researchers"
                    }
                }
            }
        }
    }

    # Compress and encode the event as it would come from Kinesis
    compressed = gzip.compress(json.dumps(cloudtrail_event).encode('utf-8'))
    encoded = base64.b64encode(compressed).decode('utf-8')

    return {
        'records': [{
            'recordId': '12345',
            'data': encoded
        }]
    }

def test_transform_function():
    """Test the transform function"""
    print("Testing transform function...")
    test_event = create_test_cloudtrail_event()

    try:
        result = transform_handler(test_event, None)

        # Decode and print the transformed result
        for record in result['records']:
            decoded = base64.b64decode(record['data']).decode('utf-8')
            print("\nTransformed output:")
            print(json.dumps(json.loads(decoded), indent=2))

        print("\nTransform test completed successfully!")

    except Exception as e:
        print(f"Transform test failed: {str(e)}")

def test_mapping_function():
    """Test the mapping function"""
    print("\nTesting mapping function...")

    # Set required environment variables for testing
    import os
    os.environ['OPENSEARCH_DOMAIN'] = 'test-domain'
    os.environ['AWS_REGION'] = 'ap-southeast-3'

    try:
        result = mapping_handler({}, None)
        print("\nMapping creation test completed!")
        print(result)

    except Exception as e:
        print(f"Mapping test failed: {str(e)}")

if __name__ == "__main__":
    print("Starting Lambda function tests...")
    test_transform_function()
    test_mapping_function()
    print("\nAll tests completed!")