resource "aws_s3_bucket" "configbucket" {
  # checkov:skip=CKV_AWS_144: For no need cross-region replication
  # checkov:skip=CKV_AWS_18: For no need to create the access log for this bucket

  bucket        = "${var.ConfigBucketName}-${var.region}"
  force_destroy = true
}
resource "aws_s3_bucket_public_access_block" "ConfigBucket" {
  bucket                  = aws_s3_bucket.configbucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.configbucket]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ConfigBucket" {
  bucket = aws_s3_bucket.configbucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "ConfigBucket" {
  bucket = aws_s3_bucket.configbucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "ConfigBucketPolicy" {
  bucket = aws_s3_bucket.configbucket.bucket

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSConfigBucketPermissionsCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.configbucket.bucket}"
    },
    {
      "Sid": "AWSConfigBucketDelivery",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.configbucket.bucket}/AWSLogs/*"
    }
  ]
}
EOF
}

resource "aws_sns_topic" "ConfigTopic" {
  count             = var.create_topic ? 1 : 0
  name              = "config-topic-${var.post_fix}"
  display_name      = "AWS Config Notification Topic"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_policy" "ConfigTopicPolicy" {
  count  = var.create_topic ? 1 : 0
  arn    = aws_sns_topic.ConfigTopic[0].arn
  policy = <<EOF
{
  "Statement": [
    {
      "Sid": "AWSConfigSNSPolicy",
      "Action": ["sns:Publish"],
      "Effect": "Allow",
      "Resource": "${aws_sns_topic.ConfigTopic[0].arn}",
      "Principal": {
        "Service": "config.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_sns_topic_subscription" "EmailNotification" {
  count     = var.create_topic ? 1 : 0
  endpoint  = var.notification_email
  protocol  = "email"
  topic_arn = aws_sns_topic.ConfigTopic[0].arn
}

resource "aws_iam_role" "ConfigRecorderRole" {
  name               = "ConfigRecorderRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_config_configuration_recorder" "ConfigRecorder" {
  role_arn   = aws_iam_role.ConfigRecorderRole.arn
  depends_on = [aws_s3_bucket_policy.ConfigBucketPolicy]

  recording_group {
    all_supported                 = var.all_supported
    include_global_resource_types = var.include_global_resource_types
    resource_types                = var.all_supported ? [] : var.resource_types
  }
}

resource "aws_config_delivery_channel" "ConfigDeliveryChannel" {
  name           = "deliverychannel-${var.post_fix}"
  depends_on     = [aws_config_configuration_recorder.ConfigRecorder]
  s3_bucket_name = aws_s3_bucket.configbucket.bucket
  sns_topic_arn  = var.create_topic ? aws_sns_topic.ConfigTopic[0].arn : null
}
