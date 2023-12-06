resource "aws_securityhub_account" "aws_securityhub_account" {
  enable_default_standards = false
}

resource "aws_securityhub_standards_subscription" "aws_securityhub" {
  depends_on    = [aws_securityhub_account.aws_securityhub_account]
  count         = var.securityhub_standards_count
  standards_arn = element(var.securityhub_standards, count.index)
}

resource "aws_securityhub_product_subscription" "prowler" {
  depends_on  = [aws_securityhub_standards_subscription.aws_securityhub]
  product_arn = "arn:aws:securityhub:${var.region}::product/prowler/prowler"
}