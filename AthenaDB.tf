resource "aws_athena_database" "example" {
  name          = "securityhubdatabase"
  bucket        = aws_s3_bucket.AthenaBucket.id
  force_destroy = true
  encryption_configuration {
    encryption_option = "SSE_S3"
  }
}

resource "aws_athena_workgroup" "example" {
  name          = "securityHubAthenaWorkgroup"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.AthenaBucket.bucket}/output/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "aws_athena_named_query" "executeCreateSecurityHubFindingsTable" {
  name        = "executeCreateSecurityHubFindingsTable"
  database    = aws_athena_database.example.name
  description = "Create Security Hub Findings Table"
  query       = <<-QUERY
    CREATE EXTERNAL TABLE IF NOT EXISTS securityhubdatabase.securityhubfindings (
      id string,
      detail struct<findings: array<struct<
        AwsAccountId: string,
        CreatedAt: string,
        UpdatedAt: string,
        Description: string,
        ProductArn: string,
        GeneratorId: string,
        Region: string,
        Compliance: struct<status: string>,
        Workflow: struct<status: string>,
        Types: string,
        Title: string,
        Severity: struct<Label: string>,
        Note: struct<Text: string>,
        Resources: array<struct<Id: string, Type: string>>
      >>>)
    PARTITIONED BY (datehour string)
    ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
    STORED AS INPUTFORMAT 'org.apache.hadoop.mapred.TextInputFormat'
    OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat'
    LOCATION 's3://${aws_s3_bucket.securityhubfindingsbucket.id}/raw/firehose'
    TBLPROPERTIES (
      'projection.datehour.format'='yyyy/MM/dd',
      'projection.datehour.interval'='1',
      'projection.datehour.interval.unit'='DAYS',
      'projection.datehour.range'='2021/07/01,NOW',
      'projection.datehour.type'='date',
      'projection.enabled'='true',
      'storage.location.template'='s3://${aws_s3_bucket.securityhubfindingsbucket.id}/raw/firehose/\$\{datehour\}'
    )
  QUERY

  workgroup = aws_athena_workgroup.example.id # Replace with your Athena workgroup
}

resource "aws_athena_named_query" "executeCreateSecurityHubFindingsView" {
  name        = "executeCreateSecurityHubFindingsView"
  database    = "your_athena_database"
  description = "Create Security Hub Findings View"
  query       = <<-QUERY
    CREATE OR REPLACE VIEW securityhubdatabase.securityhubfindingsview AS
    SELECT
      id,
      detail.findings[1].awsaccountid awsaccountid,
      detail.findings[1].CreatedAt CreatedAt,
      detail.findings[1].UpdatedAt UpdatedAt,
      detail.findings[1].ProductArn ProductArn,
      detail.findings[1].GeneratorId CheckId,
      detail.findings[1].Region Region,
      detail.findings[1].Workflow.status WorflowStatus,
      detail.findings[1].Compliance.status ComplianceStatus,
      detail.findings[1].Types FindingType,
      detail.findings[1].Title FindingTitle,
      detail.findings[1].Description FindingDescription,
      detail.findings[1].Severity.Label Severity,
      detail.findings[1].Resources[1].Type ResourceType,
      detail.findings[1].Resources[1].Id ResourceId,
      detail.findings[1].Note.Text Notes
    FROM
      securityhubdatabase.securityhubfindings
    WHERE (detail.findings[1].awsaccountid IS NOT NULL)
  QUERY

  workgroup = aws_athena_workgroup.example.id # Replace with your Athena workgroup
}
