resource "aws_kms_key" "kms_encryted_key" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}