import os
import json
import base64
import gzip
from datetime import datetime
import boto3
import requests
from requests_aws4auth import AWS4Auth
from typing import List, Dict, Optional, Any
from io import BytesIO
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

__version__ = "1.4.34"
__standard_index__ = "logs-cloudtrail"

class CloudWatchLogProcessor:
    def __init__(self):
        # Initialize tracking variables
        self.request_context = {
            'source_ip': None,
            'account_id': '',
            'user_id': '',
            'user_name': '',
            'http_method': '',
            'path': ''
        }

    @staticmethod
    @xray_recorder.capture('cloudwatch_processor_extract_json')
    def extract_json(message: str) -> Optional[Dict]:
        """Extract JSON from message if present"""
        try:
            json_start = message.find('{')
            if json_start >= 0:
                json_str = message[json_start:]
                return json.loads(json_str)
        except (json.JSONDecodeError, ValueError):
            pass
        return None

    @staticmethod
    @xray_recorder.capture('cloudwatch_processor_check_numeric')
    def is_numeric(value: str) -> bool:
        """Check if value is numeric"""
        try:
            float(value)
            return True
        except (TypeError, ValueError):
            return False

    @xray_recorder.capture('cloudwatch_extract_request_context')
    def extract_request_context(self, event_data: Dict) -> None:
        """Extract request context information from event data"""
        if isinstance(event_data, dict):
            request_context = event_data.get('requestContext', {})
            if request_context:
                # Extract identity fields
                identity = request_context.get('identity', {})
                self.request_context['source_ip'] = identity.get('sourceIp', '')
                self.request_context['account_id'] = request_context.get('accountId', '')

                # Extract authorizer claims
                authorizer = request_context.get('authorizer', {})
                claims = authorizer.get('claims', {})
                self.request_context['user_id'] = claims.get('sub', '')
                self.request_context['user_name'] = claims.get('cognito:username', '')

                # Extract path and method
                self.request_context['http_method'] = request_context.get('httpMethod', '')
                self.request_context['path'] = request_context.get('path', '')

    @xray_recorder.capture('cloudwatch_build_metadata_fields')
    def _build_metadata_fields(self) -> Dict:
        """Build metadata fields with proper null handling"""
        metadata = {
            'cw_account_id': self.request_context['account_id'],
            'cw_user_id': self.request_context['user_id'],
            'cw_user_name': self.request_context['user_name'],
            'cw_http_method': self.request_context['http_method'],
            'cw_path': self.request_context['path']
        }

        # Only add IP if it's not None and not empty
        if self.request_context['source_ip']:
            metadata['cw_ip_address'] = self.request_context['source_ip']

        return metadata

    @xray_recorder.capture('cloudwatch_processor_build_source')
    def build_source(self, message: str, extracted_fields: Optional[Dict] = None) -> Dict:
        source = {}

        if extracted_fields:
            for key, value in extracted_fields.items():
                if value:
                    if self.is_numeric(value):
                        source[key] = float(value)
                        continue

                    json_data = self.extract_json(value)
                    if json_data is not None:
                        source[f'${key}'] = json_data

                    source[key] = value

        # Try to parse entire message as JSON
        json_data = self.extract_json(message)
        if json_data is not None:
            source.update(json_data)

        return source

    @xray_recorder.capture('cloudwatch_processor_process_payload')
    def process_payload(self, payload: Dict) -> List[Dict]:
        """Process CloudWatch Logs payload"""
        if payload.get('messageType') == 'CONTROL_MESSAGE':
            return []

        processed_logs = []
        for log_event in payload.get('logEvents', []):
            timestamp = datetime.fromtimestamp(log_event['timestamp'] / 1000.0)
            message = log_event['message']

            # Start with base metadata
            source = {
                '@timestamp': timestamp.isoformat(),
                '@id': log_event['id'],
                '@message': message,
                '@owner': payload.get('owner'),
                '@log_group': payload.get('logGroup'),
                '@log_stream': payload.get('logStream')
            }

            # Try JSON parsing first
            json_data = self.extract_json(message)
            if json_data is not None:
                source.update(json_data)
                source['event_type'] = 'json'
                self.extract_request_context(json_data)
            else:
                # Not JSON - check for specific message patterns
                if "START RequestId:" in message:
                    source['event_type'] = 'lambda_start'
                    request_id = message.split("START RequestId:", 1)[1].strip().split()[0]
                    source['request_id'] = request_id
                elif "END RequestId:" in message:
                    source['event_type'] = 'lambda_end'
                    request_id = message.split("END RequestId:", 1)[1].strip().split()[0]
                    source['request_id'] = request_id
                elif "REPORT RequestId:" in message:
                    source['event_type'] = 'lambda_report'
                    parts = message.split('\t')
                    for part in parts:
                        if "Duration:" in part:
                            try:
                                source['duration_ms'] = float(part.split(':')[1].strip().replace(" ms", ""))
                            except (ValueError, IndexError):
                                pass
                        elif "Memory Used:" in part:
                            try:
                                source['memory_used_mb'] = float(part.split(':')[1].strip().replace(" MB", ""))
                            except (ValueError, IndexError):
                                pass
                elif "Event Received:" in message:
                    source['event_type'] = 'event_received'
                    try:
                        json_start = message.find('{')
                        if json_start >= 0:
                            json_content = message[json_start:]
                            event_data = json.loads(json_content)
                            source['event_data'] = event_data
                            self.extract_request_context(event_data)
                    except (json.JSONDecodeError, ValueError):
                        continue
                elif "Response Body:" in message:
                    source['event_type'] = 'response_body'
                    try:
                        response_content = message.split("Response Body:", 1)[1].strip()
                        response_data = json.loads(response_content)
                        source['response_data'] = response_data

                        if isinstance(response_data, dict):
                            source.update({
                                'status': response_data.get('status'),
                                'volumeSize': response_data.get('volumeSize'),
                                'instanceType': response_data.get('instanceType')
                            })
                    except (json.JSONDecodeError, ValueError) as e:
                        print(f"Failed to parse Response Body JSON: {str(e)}")
                        continue
                else:
                    # Skip logs that don't match any known patterns
                    continue

            # Process any extracted fields
            if log_event.get('extractedFields'):
                extracted_source = self.build_source(message, log_event['extractedFields'])
                if extracted_source:
                    source.update(extracted_source)

            # Use the new metadata builder
            source.update(self._build_metadata_fields())
            source['lambda_version'] = __version__
            processed_logs.append(source)
            print(f"Processed log entry: {source.get('@id')} - Type: {source.get('event_type')}")

        return processed_logs

class OpenSearchManager:
    def __init__(self):
        self.domain = os.environ['OPENSEARCH_DOMAIN_ENDPOINT']
        self.region = os.environ.get('REGION', 'ap-southeast-3')
        self.environment = os.environ.get('ENVIRONMENT', 'dev')
        self.auth = self._get_aws_auth()
        self._ensure_index_template()

    @xray_recorder.capture('get_aws_auth')
    def _get_aws_auth(self) -> AWS4Auth:
        """Get AWS authentication credentials with proper error handling"""
        try:
            session = boto3.Session()
            credentials = session.get_credentials()
            if not credentials:
                raise Exception("No AWS credentials found")

            frozen_credentials = credentials.get_frozen_credentials()
            return AWS4Auth(
                frozen_credentials.access_key,
                frozen_credentials.secret_key,
                self.region,
                'es',
                session_token=frozen_credentials.token
            )
        except Exception as e:
            print(f"Error getting AWS credentials: {str(e)}")
            raise

    @xray_recorder.capture('opensearch_request')
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        retry=retry_if_exception_type(requests.exceptions.RequestException)
    )
    def _make_request(self, method: str, endpoint: str, data: str = None) -> requests.Response:
        """Make HTTP request to OpenSearch with X-Ray tracing"""
        url = f"https://{self.domain}/{endpoint}"
        headers = {"Content-Type": "application/json"}

        subsegment = xray_recorder.begin_subsegment('opensearch_api_call')
        try:
            subsegment.put_annotation('endpoint', endpoint)
            subsegment.put_annotation('method', method)

            response = requests.request(
                method=method,
                url=url,
                auth=self.auth,
                headers=headers,
                data=data,
                verify=True,
                timeout=30
            )

            subsegment.put_annotation('status_code', response.status_code)

            if response.status_code >= 400:
                error_body = response.text[:1000]
                subsegment.put_annotation('error', error_body)
                print(f"OpenSearch error: Status {response.status_code}, Body: {error_body}")
                print(f"Request URL: {url}")

            response.raise_for_status()
            return response

        except Exception as e:
            subsegment.put_annotation('error', str(e))
            print(f"Request failed: {str(e)}")
            print(f"Request URL: {url}")
            raise
        finally:
            xray_recorder.end_subsegment()

    @xray_recorder.capture('opensearch_index_template')
    def _ensure_index_template(self):
        """Create or update index template with proper mappings"""
        template = {
            "index_patterns": [f"{__standard_index__}-*"],
            "template": {
                "settings": {
                    "number_of_shards": 1,
                    "number_of_replicas": 1
                },
                "mappings": {
                    "dynamic_templates": [
                        {
                            "strings_as_keywords": {
                                "match_mapping_type": "string",
                                "path_match": "requestParameters.*",
                                "mapping": {
                                    "type": "keyword",
                                    "null_value": ""
                                }
                            }
                        },
                        {
                            "tag_values": {
                                "path_match": "*.[tT]ag.[vV]alue",
                                "mapping": {
                                    "type": "keyword",
                                    "null_value": ""
                                }
                            }
                        }
                    ],
                    "properties": {
                        "event_type": {"type": "keyword"},
                        "@timestamp": {"type": "date"},
                        "@message": {"type": "text"},
                        "@id": {"type": "keyword"},
                        "@log_group": {"type": "keyword"},
                        "@log_stream": {"type": "keyword"},
                        "requestParameters": {
                            "type": "object",
                            "dynamic": True
                        },
                        "responseElements": {
                            "type": "object",
                            "dynamic": True
                        },
                        "requestContext": {
                            "properties": {
                                "identity": {
                                    "properties": {
                                        "sourceIp": {"type": "ip"},
                                        "accountId": {"type": "keyword"}
                                    }
                                },
                                "authorizer": {
                                    "properties": {
                                        "claims": {
                                            "properties": {
                                                "sub": {"type": "keyword"},
                                                "cognito-username": {"type": "keyword"}
                                            }
                                        }
                                    }
                                },
                                "source_ip": {"type": "ip"},
                                "account_id": {"type": "keyword"},
                                "user_id": {"type": "keyword"},
                                "user_name": {"type": "keyword"},
                                "httpMethod": {"type": "keyword"},
                                "path": {"type": "keyword"}
                            }
                        },
                        "response_data": {
                            "properties": {
                                "status": {"type": "keyword"},
                                "volumeSize": {"type": "long"},
                                "instanceType": {"type": "keyword"}
                            }
                        },
                        "cw_ip_address": {"type": "ip"},
                        "cw_account_id": {"type": "keyword"},
                        "cw_user_id": {"type": "keyword"},
                        "cw_user_name": {"type": "keyword"},
                        "cw_http_method": {"type": "keyword"},
                        "cw_path": {"type": "keyword"},
                        "lambda_version": {"type": "keyword"}
                    }
                }
            }
        }

        try:
            response = self._make_request('PUT', '_index_template/cw_template',
                                        data=json.dumps(template))
            print(f"Successfully created/updated index template: {response.status_code}")
        except Exception as e:
            print(f"Failed to create/update index template: {str(e)}")
            raise

    @xray_recorder.capture('opensearch_normalize_document')
    def _normalize_document(self, doc: Dict) -> Dict:
        """Normalize document fields before indexing"""
        def normalize_value(value):
            if isinstance(value, bool):
                return str(value).lower()
            if value is None:
                return ""
            return str(value)

        def process_dict(d):
            if d is None:
                return {}

            processed = {}
            for key, value in d.items():
                if isinstance(value, dict):
                    processed[key] = process_dict(value)
                elif isinstance(value, list):
                    processed[key] = [process_dict(item) if isinstance(item, dict)
                                    else normalize_value(item) for item in value]
                elif key == "Value" and any(tag_key in str(key) for tag_key in ["Tag", "TagSet"]):
                    processed[key] = normalize_value(value)
                else:
                    processed[key] = normalize_value(value)
            return processed

        try:
            normalized = doc.copy()
            if 'requestParameters' in normalized:
                normalized['requestParameters'] = process_dict(normalized.get('requestParameters'))

            # Also normalize any Tag values in responseElements
            if 'responseElements' in normalized:
                normalized['responseElements'] = process_dict(normalized.get('responseElements'))

            return normalized

        except Exception as e:
            print(f"Error normalizing document: {str(e)}")
            print(f"Problem document: {json.dumps(doc)[:1000]}...")
            # Return original document if normalization fails
            return doc

    @xray_recorder.capture('opensearch_bulk_index')
    def bulk_index(self, documents: List[Dict]) -> Dict:
        if not documents:
            return {"took": 0, "errors": False, "items": []}

        subsegment = xray_recorder.begin_subsegment('bulk_index_preparation')
        try:
            bulk_body = []
            current_date = datetime.now().strftime('%Y.%m.%d')
            index_name = f"{__standard_index__}-{current_date}"

            for doc in documents:
                # Normalize document before indexing
                normalized_doc = self._normalize_document(doc)

                index_action = {
                    "index": {
                        "_index": index_name,
                        "_id": normalized_doc.get('@id')
                    }
                }

                if not index_action["index"]["_id"]:
                    del index_action["index"]["_id"]

                bulk_body.extend([
                    json.dumps(index_action),
                    json.dumps(normalized_doc)
                ])

            bulk_request = "\n".join(bulk_body) + "\n"
            print(f"Attempting to bulk index {len(documents)} documents to {index_name}")

            # Add trace metadata
            subsegment.put_metadata('document_count', len(documents))
            subsegment.put_metadata('index_name', index_name)

            response = self._make_request('POST', '_bulk', data=bulk_request)
            result = response.json()

            if result.get('errors', False):
                failed_items = [item for item in result.get('items', [])
                              if item.get('index', {}).get('status', 200) >= 400]
                if failed_items:
                    error_summary = f"Bulk indexing errors: {len(failed_items)} failures out of {len(documents)} documents"
                    subsegment.put_annotation('indexing_errors', error_summary)
                    print(f"{error_summary}. First few failures: {json.dumps(failed_items[:2], indent=2)}")

            return result

        except Exception as e:
            if subsegment:
                subsegment.put_annotation('error', str(e))
            print(f"Error in bulk_index: {str(e)}")
            raise
        finally:
            xray_recorder.end_subsegment()

@xray_recorder.capture('kinisis_record_processing')
def process_kinesis_record(record: Dict) -> List[Dict]:
    """Process a record from Kinesis Stream"""
    try:
        # Decode kinesis data
        payload = base64.b64decode(record['kinesis']['data'])
        print(f"Decoded payload size: {len(payload)} bytes")

        # Handle CloudWatch Logs compressed format
        if 'kinesisSchemaVersion' in record['kinesis']:
            compressed_payload = BytesIO(payload)
            with gzip.GzipFile(fileobj=compressed_payload, mode='r') as gz:
                payload = gz.read()
                # print(f"Decompressed data size: {len(payload)} bytes")

        # Parse the JSON payload
        log_event = json.loads(payload.decode('utf-8'))
        processor = CloudWatchLogProcessor()

        if 'logEvents' in log_event:
            return processor.process_payload(log_event)
        else:
            # Handle direct JSON records
            return [{
                '@timestamp': datetime.utcnow().isoformat(),
                **log_event
            }]
    except Exception as e:
        print(f"Error processing Kinesis record: {str(e)}")
        return []

@xray_recorder.capture('lambda_handler')
def handler(event: Dict, context: Any) -> Dict:
    start_time = datetime.now()

    try:
        opensearch = OpenSearchManager()
        processed_logs = []
        output_records = []

        # Determine if this is a Kinesis Stream or Firehose event
        if 'Records' in event:
            # Kinesis Stream
            print(f"Processing {len(event['Records'])} Kinesis records")
            for record in event['Records']:
                processed_logs.extend(process_kinesis_record(record))

            if processed_logs:
                opensearch.bulk_index(processed_logs)

            return {
                'statusCode': 200,
                'body': json.dumps(f'Successfully processed {len(processed_logs)} logs')
            }
        else:
            # Kinesis Firehose
            print(f"Processing {len(event.get('records', []))} Firehose records")
            processor = CloudWatchLogProcessor()  # Create processor instance

            for record in event.get('records', []):
                try:
                    # Decode and decompress
                    payload = json.loads(
                        gzip.decompress(
                            base64.b64decode(record['data'])
                        ).decode('utf-8')
                    )

                    # Process logs using instance method
                    batch_logs = processor.process_payload(payload)
                    processed_logs.extend(batch_logs)

                    # Mark as processed
                    output_records.append({
                        'recordId': record['recordId'],
                        'result': 'Ok',
                        'data': record['data']
                    })

                except Exception as e:
                    print(f"Error processing Firehose record: {str(e)}")
                    print(f"Payload snippet: {str(payload)[:200]}")  # Added for debugging
                    output_records.append({
                        'recordId': record['recordId'],
                        'result': 'ProcessingFailed',
                        'data': record['data']
                    })

            # Index processed logs
            if processed_logs:
                opensearch.bulk_index(processed_logs)

            # Print execution duration and stats
            duration_ms = (datetime.now() - start_time).total_seconds() * 1000
            print(f"Execution Stats:")
            print(f"- Duration: {duration_ms:.2f}ms")
            print(f"- Memory Configured: {context.memory_limit_in_mb}MB")
            print(f"- Logs Processed: {len(processed_logs)}")
            print(f"- Time Remaining: {context.get_remaining_time_in_millis() / 1000:.2f}s")

            return {'records': output_records}

    except Exception as e:
        print(f"Error in handler: {str(e)}")
        raise