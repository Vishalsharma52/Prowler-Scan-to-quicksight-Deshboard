resource "aws_quicksight_account_subscription" "subscription" {
  depends_on            = [aws_iam_role_policy_attachment.example_attachment1]
  account_name          = "prowler-quicksight-terraform"
  authentication_method = "IAM_ONLY"
  edition               = "ENTERPRISE"
  notification_email    = "vishal.sharma@inadev.com"
}

resource "aws_quicksight_data_source" "AthenaDataSource" {
  depends_on     = [aws_quicksight_account_subscription.subscription]
  data_source_id = "ProwlerSecuirtydashboard-id"
  name           = "ProwlerSecuirtydashboard-id"
  type           = "ATHENA"
  parameters {
    athena {
      work_group = aws_athena_workgroup.example.id
    }
  }
}

resource "aws_quicksight_data_set" "athena_data_set" {
  depends_on  = [aws_quicksight_data_source.AthenaDataSource]
  data_set_id = "AthenaDataSet"
  name        = "AthenaDataSet"
  import_mode = "SPICE" # or "DIRECT_QUERY" based on your preference
  physical_table_map {
    physical_table_map_id = "Test-1"
    relational_table {
      name            = "securityhubfindingsview"
      data_source_arn = aws_quicksight_data_source.AthenaDataSource.arn
      catalog         = "AwsDataCatalog"
      dynamic "input_columns" {
        for_each = var.column_definitions
        iterator = column_definitions
        content {
          name = column_definitions.value.name
          type = column_definitions.value.type
        }
      }
      schema = "securityhubdatabase"
    }
  }
}


data "aws_iam_role" "quicksightrole" {
  name = "aws-quicksight-service-role-v0"
}

output "athena_data_set" {
  value = aws_quicksight_data_set.athena_data_set.arn
}



