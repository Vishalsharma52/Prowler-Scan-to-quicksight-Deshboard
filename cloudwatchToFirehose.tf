resource "aws_cloudwatch_event_target" "sentTokinesis" {
  rule      = aws_cloudwatch_event_rule.SecurityHubCloudWatchEvent.name
  role_arn  = aws_iam_role.SecurityHubLogDeliveryRole.arn
  arn       = aws_kinesis_firehose_delivery_stream.FireHoseDeliveryStream.arn
  target_id = "firehose_target"
}

resource "aws_cloudwatch_event_rule" "SecurityHubCloudWatchEvent" {
  name          = "SecurityHubEventRule"
  description   = "Exports SecurityHub findings to S3"
  role_arn      = aws_iam_role.SecurityHubLogDeliveryRole.arn
  event_pattern = <<EOF
{
  "source": [
    "aws.securityhub"
  ]
}
EOF
}

resource "aws_kinesis_firehose_delivery_stream" "FireHoseDeliveryStream" {
  name        = "SecurityHubFirehose"
  destination = "extended_s3"


  extended_s3_configuration {
    bucket_arn         = aws_s3_bucket.securityhubfindingsbucket.arn
    role_arn           = aws_iam_role.FirehoseDeliveryRole.arn
    prefix             = "raw/firehose/"
    buffering_interval = 60
    buffering_size     = 5
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "Firehose-logs"
      log_stream_name = "Delivery_logs"
    }

    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = aws_lambda_function.LambdaFunctionKdfTransformation.arn
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "1"
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "180"
        }
      }
    }
  }
  server_side_encryption {
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = aws_kms_key.kms_encryted_key.arn
  }
}



