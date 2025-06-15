resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "my-test-terraform-bucket-202504"  # 一意な名前に！
  force_destroy = true  # terraform destroy 時に中身ごと削除
}
