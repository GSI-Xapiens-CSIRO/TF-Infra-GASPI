# ==========================================================================
#  Module S3 Logs: s3-logs-athena.tf
# --------------------------------------------------------------------------
#  Description:
#    S3 Logs Athena
# --------------------------------------------------------------------------
#    - Bucket Logs
#    - Bucket Versioning
#    - Bucket Encryption
#    - Bucket Lifecycle
#    - Bucket Policy
# ==========================================================================

# Athena workgroup for log analysis
resource "aws_athena_workgroup" "logs_analysis" {
  provider = aws.destination
  name     = "gxc-sbeacon-logs-analysis"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.logs.id}/athena-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = merge(local.tags, var.common_tags)
}

# Athena database for logs
resource "aws_glue_catalog_database" "logs" {
  provider    = aws.destination
  name        = "gxc_sbeacon_logs"
  description = "Database for GXC sBeacon logs analysis"
}

# Glue tables for different log types
resource "aws_glue_catalog_table" "cloudfront_logs" {
  provider      = aws.destination
  name          = "cloudfront_logs"
  database_name = aws_glue_catalog_database.logs.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                 = "TRUE"
    "classification"         = "csv"
    "csvDelimiter"           = "\t"
    "skip.header.line.count" = "2"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.logs.id}/frontend/*/cloudfront/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = "\t"
      }
    }

    # CloudFront log columns
    columns {
      name = "date"
      type = "date"
    }
    columns {
      name = "time"
      type = "string"
    }
    columns {
      name = "edge_location"
      type = "string"
    }
    columns {
      name = "bytes_sent"
      type = "bigint"
    }
    columns {
      name = "ip"
      type = "string"
    }
    columns {
      name = "method"
      type = "string"
    }
    columns {
      name = "host"
      type = "string"
    }
    columns {
      name = "uri"
      type = "string"
    }
    columns {
      name = "status"
      type = "int"
    }
    columns {
      name = "referrer"
      type = "string"
    }
    columns {
      name = "user_agent"
      type = "string"
    }
    columns {
      name = "query_string"
      type = "string"
    }
    columns {
      name = "cookie"
      type = "string"
    }
    columns {
      name = "result_type"
      type = "string"
    }
    columns {
      name = "request_id"
      type = "string"
    }
    columns {
      name = "host_header"
      type = "string"
    }
    columns {
      name = "protocol"
      type = "string"
    }
    columns {
      name = "bytes_received"
      type = "bigint"
    }
    columns {
      name = "time_taken"
      type = "float"
    }
  }
}

resource "aws_glue_catalog_table" "lambda_logs" {
  provider      = aws.destination
  name          = "lambda_logs"
  database_name = aws_glue_catalog_database.logs.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL         = "TRUE"
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.logs.id}/backend/*/lambda/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    # Lambda log columns
    columns {
      name = "timestamp"
      type = "timestamp"
    }
    columns {
      name = "message"
      type = "string"
    }
    columns {
      name = "log_level"
      type = "string"
    }
    columns {
      name = "function_name"
      type = "string"
    }
    columns {
      name = "request_id"
      type = "string"
    }
    columns {
      name = "duration"
      type = "double"
    }
    columns {
      name = "memory_used"
      type = "bigint"
    }
    columns {
      name = "max_memory"
      type = "bigint"
    }
  }
}

# Sample queries saved in Athena
resource "aws_athena_named_query" "cloudfront_error_rates" {
  provider    = aws.destination
  name        = "cloudfront-error-rates"
  workgroup   = aws_athena_workgroup.logs_analysis.name
  database    = aws_glue_catalog_database.logs.name
  description = "Calculate error rates by status code"

  query = <<EOF
SELECT
  date,
  status,
  COUNT(*) as requests,
  COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY date) as error_rate
FROM cloudfront_logs
WHERE status >= 400
GROUP BY date, status
ORDER BY date DESC, status
EOF
}

resource "aws_athena_named_query" "lambda_errors" {
  provider    = aws.destination
  name        = "lambda-errors"
  workgroup   = aws_athena_workgroup.logs_analysis.name
  database    = aws_glue_catalog_database.logs.name
  description = "Find Lambda function errors"

  query = <<EOF
SELECT
  timestamp,
  function_name,
  message,
  duration,
  memory_used
FROM lambda_logs
WHERE log_level = 'ERROR'
ORDER BY timestamp DESC
LIMIT 100
EOF
}
