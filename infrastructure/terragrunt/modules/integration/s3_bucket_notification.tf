resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_id

  queue {
    queue_arn     = snowflake_pipe.pipe.notification_channel
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".csv"
  }
}

resource "aws_s3_bucket_notification" "fighters_bucket_notification" {
  bucket = var.bucket_id

  queue {
    queue_arn     = snowflake_pipe.fighters_pipe.notification_channel
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".csv"
  }
}
