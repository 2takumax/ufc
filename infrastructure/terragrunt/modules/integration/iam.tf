resource "aws_iam_policy" "policy" {
  name        = "snowflake_integration"
  path        = "/"
  description = "snowflakeのS3へのアクセス用"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        "Resource" : "arn:aws:s3:::${var.bucket_id}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : "arn:aws:s3:::${var.bucket_id}"
      }
    ]
  })
}

resource "aws_iam_role" "snowflake" {
  name = var.snowflake_iam_role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "AWS" : "${snowflake_storage_integration.s3_int.storage_aws_iam_user_arn}"
        },
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : "${snowflake_storage_integration.s3_int.storage_aws_external_id}"
          }
        }
      }
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.snowflake.name
  policy_arn = aws_iam_policy.policy.arn
}
