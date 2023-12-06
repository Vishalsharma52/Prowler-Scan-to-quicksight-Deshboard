resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  depends_on = [aws_s3_bucket.securityhubfindingsbucket]
  bucket     = aws_s3_bucket.securityhubfindingsbucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.LambdaFunctionExecuteQuery.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.LambdaFunctionExecuteQuery.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.securityhubfindingsbucket.id}"
}

resource "aws_lambda_function" "LambdaFunctionExecuteQuery" {
  # checkov:skip=CKV_AWS_117: If we place this lambda in VPC its unable to reache athena service and for that we need to create extra NAT Gateway.
  function_name = "LambdaFunctionExecuteQuery"
  handler       = "ExecuteCreateSecurityHubFindingsView.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.IAMRoleExecuteQueryAthena.arn
  filename      = "./ExecuteCreateSecurityHubFindingsView.zip"
  kms_key_arn   = aws_kms_key.kms_encryted_key.arn
  depends_on    = [aws_s3_bucket.securityhubfindingsbucket, data.aws_caller_identity.current]
  environment {
    variables = {
      NAMED_QUERIES        = "${aws_athena_named_query.executeCreateSecurityHubFindingsTable.id},${aws_athena_named_query.executeCreateSecurityHubFindingsView.id}"
      ATHENA_DATABASE      = aws_athena_database.example.id,
      ATHENA_WORKGROUP     = aws_athena_workgroup.example.id,
      ATHENA_OUTPUT_BUCKET = aws_s3_bucket.AthenaBucket.id,
      DATA_SET_ID          = aws_quicksight_data_set.athena_data_set.data_set_id,
      AWSACCOUNTId         = data.aws_caller_identity.current.account_id
    }
  }
  tracing_config {
    mode = "PassThrough"
  }
  dead_letter_config {
    target_arn = aws_sns_topic.ConfigTopic[0].arn
  }
}

resource "aws_lambda_function" "LambdaFunctionKdfTransformation" {
  # checkov:skip=CKV_AWS_173: no env variable required
  filename      = "./Transformcode.zip"
  function_name = "LambdaFunctionKdfTransformation"
  handler       = "Transformcode.lambda_handler"
  role          = aws_iam_role.IAMRoleLambdaKdfTransformation.arn
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 300
  kms_key_arn   = aws_kms_key.kms_encryted_key.arn
  tracing_config {
    mode = "PassThrough"
  }
  vpc_config {
    subnet_ids         = (var.subnet_ids == null) ? var.subnet_ids : data.aws_subnets.selected.ids
    security_group_ids = (var.security_groups == null) ? var.security_groups : data.aws_security_groups.test.ids
  }
  dead_letter_config {
    target_arn = aws_sns_topic.ConfigTopic[0].arn
  }
}
data "aws_caller_identity" "current" {}
