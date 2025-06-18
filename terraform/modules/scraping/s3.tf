resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = var.aws_s3_bucket
  force_destroy = true # terraform destroy 時に中身ごと削除
}
