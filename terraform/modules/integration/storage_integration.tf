resource "snowflake_storage_integration" "s3_int" {
  name    = "s3_int"
  comment = "A storage integration."
  type    = "EXTERNAL_STAGE"

  enabled = true

  storage_allowed_locations = ["*"]
  #   storage_blocked_locations = [""]
  #   storage_aws_object_acl    = "bucket-owner-full-control"

  storage_provider         = "S3"
#   storage_aws_external_id  = "..."
#   storage_aws_iam_user_arn = "..."
  storage_aws_role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.snowflake_iam_role_name}"
}
