resource "aws_s3_bucket" "AthenaBucket" {
  # checkov:skip=CKV_AWS_144: cross region not required
  # checkov:skip=CKV_AWS_18: access logs are not required
  bucket        = "bucketathenaworkgroup-${var.region}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "AthenaBucketaccess" {
  bucket                  = aws_s3_bucket.AthenaBucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.AthenaBucket]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "AthenaBucketencryption" {
  bucket = aws_s3_bucket.AthenaBucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "AthenaBucket" {
  bucket = aws_s3_bucket.AthenaBucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

################## Finding Bucket ##################

resource "aws_s3_bucket" "securityhubfindingsbucket" {
  # checkov:skip=CKV_AWS_18: access key are not required
  # checkov:skip=CKV_AWS_144: cross region not required
  bucket        = "securityhubfindingsbucketforprowler-${var.region}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "securityhubfindingsbucketaccess" {
  bucket                  = aws_s3_bucket.securityhubfindingsbucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.securityhubfindingsbucket]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "securityfindingsencryption" {
  bucket = aws_s3_bucket.securityhubfindingsbucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "securityhubfindingsbucket" {
  bucket = aws_s3_bucket.securityhubfindingsbucket.id
  versioning_configuration {
    status = "Enabled"
  }
}