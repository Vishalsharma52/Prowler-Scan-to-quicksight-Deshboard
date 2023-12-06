resource "aws_iam_role" "SecurityHubLogDeliveryRole" {
  name = "SecurityHubLogDeliveryRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  inline_policy {
    name = "PutKinesisFirehosePolicy"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "firehose:PutRecord",
        "firehose:PutRecordBatch" 
      ],
      "Resource": "${aws_kinesis_firehose_delivery_stream.FireHoseDeliveryStream.arn}"
    },
    {
        "Effect": "Allow",
        "Action":[
        "logs:CreateLogGroup", 
        "logs:CreateLogStream", 
        "logs:PutLogEvents"
        ],
        "Resource": "*"
    }
  ]
}
EOF
  }
}

resource "aws_iam_role" "FirehoseDeliveryRole" {
  name = "FirehoseDeliveryRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "FirehoseDeliveryPolicy" {
  name        = "SecurityHubFirehoseDeliveryPolicy"
  description = "Policy for SecurityHub Firehose Delivery Role"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.securityhubfindingsbucket.arn}",
        "${aws_s3_bucket.securityhubfindingsbucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction" 
      ],
      "Resource": "${aws_lambda_function.LambdaFunctionKdfTransformation.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup", 
        "logs:CreateLogStream", 
        "logs:PutLogEvents" 
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example_attachment" {
  policy_arn = aws_iam_policy.FirehoseDeliveryPolicy.arn
  role       = aws_iam_role.FirehoseDeliveryRole.name
}

resource "aws_iam_role" "IAMRoleLambdaKdfTransformation" {
  name = "IAMRoleLambdaKdfTransformation-vishal1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  inline_policy {
    name = "Logs_for_lambda"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup", 
        "logs:CreateLogStream", 
        "logs:PutLogEvents" 
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
				"ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:*"
      ],
      "Resource": "${aws_sns_topic.ConfigTopic[0].arn}"
    }
  ]
}
EOF
  }
}

resource "aws_iam_role" "IAMRoleExecuteQueryAthena" {
  name = "IAMRoleExecuteQueryAthena"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  inline_policy {
    name   = "Athena-required-policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.securityhubfindingsbucket.arn}",
        "${aws_s3_bucket.securityhubfindingsbucket.arn}/*",
        "${aws_s3_bucket.AthenaBucket.arn}",
        "${aws_s3_bucket.AthenaBucket.arn}/*"
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "glue:*"
      ],
      "Resource": [
        "arn:aws:glue:*:*:catalog",
        "arn:aws:glue:*:*:database/*",
        "arn:aws:glue:*:*:table/*/*" 
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
				"ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "athena:*"
      ],
      "Resource": ["${aws_athena_workgroup.example.arn}","${aws_athena_workgroup.example.arn}/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:*"
      ],
      "Resource": "${aws_sns_topic.ConfigTopic[0].arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup", 
        "logs:CreateLogStream", 
        "logs:PutLogEvents",
        "quicksight:CreateIngestion" 
      ],
      "Resource": "*"
    }
  ]
}
EOF
  }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

resource "aws_s3_bucket_policy" "SecurityHubFindingsBucketPolicy" {
  bucket = aws_s3_bucket.securityhubfindingsbucket.bucket

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.securityhubfindingsbucket.arn}",
        "${aws_s3_bucket.securityhubfindingsbucket.arn}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": false
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "quicksightpolicy" {
  name        = "QuicksightAthenapolicy"
  description = "Quicksight policy to access athena & s3"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "athena:BatchGetQueryExecution",
                "athena:CancelQueryExecution",
                "athena:GetCatalogs",
                "athena:GetExecutionEngine",
                "athena:GetExecutionEngines",
                "athena:GetNamespace",
                "athena:GetNamespaces",
                "athena:GetQueryExecution",
                "athena:GetQueryExecutions",
                "athena:GetQueryResults",
                "athena:GetQueryResultsStream",
                "athena:GetTable",
                "athena:GetTables",
                "athena:ListQueryExecutions",
                "athena:RunQuery",
                "athena:StartQueryExecution",
                "athena:StopQueryExecution",
                "athena:ListWorkGroups",
                "athena:ListEngineVersions",
                "athena:GetWorkGroup",
                "athena:GetDataCatalog",
                "athena:GetDatabase",
                "athena:GetTableMetadata",
                "athena:ListDataCatalogs",
                "athena:ListDatabases",
                "athena:ListTableMetadata"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:CreateDatabase",
                "glue:DeleteDatabase",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:UpdateDatabase",
                "glue:CreateTable",
                "glue:DeleteTable",
                "glue:BatchDeleteTable",
                "glue:UpdateTable",
                "glue:GetTable",
                "glue:GetTables",
                "glue:BatchCreatePartition",
                "glue:CreatePartition",
                "glue:DeletePartition",
                "glue:BatchDeletePartition",
                "glue:UpdatePartition",
                "glue:GetPartition",
                "glue:GetPartitions",
                "glue:BatchGetPartition"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:ListMultipartUploadParts",
                "s3:AbortMultipartUpload",
                "s3:CreateBucket",
                "s3:PutObject",
                "s3:PutBucketPublicAccessBlock"
            ],
            "Resource": [
                "${aws_s3_bucket.securityhubfindingsbucket.arn}",
                "${aws_s3_bucket.securityhubfindingsbucket.arn}/*",
                "${aws_s3_bucket.AthenaBucket.arn}",
                "${aws_s3_bucket.AthenaBucket.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lakeformation:GetDataAccess"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example_attachment1" {
  policy_arn = aws_iam_policy.quicksightpolicy.arn
  role       = data.aws_iam_role.quicksightrole.id
}