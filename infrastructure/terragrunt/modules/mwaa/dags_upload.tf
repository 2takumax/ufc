# DAGsをS3にアップロード

# ETL DAGファイルをS3にアップロード
resource "aws_s3_object" "etl_dags" {
  for_each = var.upload_dags ? fileset("${var.dags_path}/etl_dags/", "*.py") : toset([])

  bucket = var.create_s3_bucket ? aws_s3_bucket.mwaa[0].id : var.source_bucket_name
  key    = "dags/${each.value}"
  source = "${var.dags_path}/etl_dags/${each.value}"
  etag   = filemd5("${var.dags_path}/etl_dags/${each.value}")
}


# dbtプロジェクトをzipして S3にアップロード
data "archive_file" "dbt_project" {
  count = var.upload_dbt_project ? 1 : 0
  
  type        = "zip"
  source_dir  = "${var.dags_path}/dbt"
  output_path = "${path.module}/dbt_project.zip"
}

resource "aws_s3_object" "dbt_project" {
  count = var.upload_dbt_project ? 1 : 0

  bucket = var.create_s3_bucket ? aws_s3_bucket.mwaa[0].id : var.source_bucket_name
  key    = "plugins/dbt_project.zip"
  source = data.archive_file.dbt_project[0].output_path
  etag   = data.archive_file.dbt_project[0].output_md5
}

# requirements.txtをS3にアップロード
resource "aws_s3_object" "requirements" {
  count = var.upload_requirements ? 1 : 0

  bucket = var.create_s3_bucket ? aws_s3_bucket.mwaa[0].id : var.source_bucket_name
  key    = "requirements.txt"
  source = "${var.dags_path}/requirements.txt"
  etag   = filemd5("${var.dags_path}/requirements.txt")
}