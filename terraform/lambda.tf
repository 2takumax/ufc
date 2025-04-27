data "archive_file" "test_terraform" {
  type        = "zip"
  source_dir  = "../scraping/scrape_events"
  output_path = "../scraping/scrape_events/scraping.zip"
}

resource "aws_lambda_function" "test_terraform" {
  function_name    = "test_terraform"
  filename         = data.archive_file.test_terraform.output_path
  source_code_hash = data.archive_file.test_terraform.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "lambda_function.lambda_handler"
  timeout          = 180
  layers           = [
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-numpy:11",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pandas:15",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-requests:12",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-beautifulsoup4:5",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pyyaml:1"
  ]
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "run-test-terraform-daily"
  description         = "Triggers test_terraform lambda daily at 6AM JST"
  schedule_expression = "cron(0 18 ? * 1 *)"  # UTCで前日の21:00 = JST 6:00
}

resource "aws_cloudwatch_event_target" "test_terraform_trigger" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "test_terraform_lambda"
  arn       = aws_lambda_function.test_terraform.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_terraform.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "my-test-terraform-bucket-202504"  # 一意な名前に！
  force_destroy = true  # terraform destroy 時に中身ごと削除
}

data "archive_file" "test_odds" {
  type        = "zip"
  source_dir  = "../scraping/scrape_odds"
  output_path = "../scraping/scrape_odds/scraping.zip"
}

resource "aws_lambda_function" "test_odds" {
  function_name    = "test_odds"
  filename         = data.archive_file.test_odds.output_path
  source_code_hash = data.archive_file.test_odds.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "scrape_odds.lambda_handler"
  timeout          = 180
  layers           = [
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-numpy:11",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pandas:15",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-requests:12",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-beautifulsoup4:5"
  ]
}
