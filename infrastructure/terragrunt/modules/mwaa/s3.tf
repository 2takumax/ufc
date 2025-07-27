resource "aws_s3_bucket" "mwaa" {
  count = var.create_s3_bucket ? 1 : 0

  bucket        = var.source_bucket_name
#   bucket_prefix = local.source_bucket_prefix

#   tags = var.tags
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "mwaa" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.mwaa[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "mwaa" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.mwaa[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "mwaa" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.mwaa[0].id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
