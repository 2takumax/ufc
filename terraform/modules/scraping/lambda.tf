data "archive_file" "test_terraform" {
  type        = "zip"
  source_dir  = "${path.module}/script/scrape_events"
  output_path = "${path.module}/script/scrape_events/scraping.zip"
}

resource "aws_lambda_function" "test_terraform" {
  function_name    = "scrape_events"
  filename         = data.archive_file.test_terraform.output_path
  source_code_hash = data.archive_file.test_terraform.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "lambda_function.lambda_handler"
  timeout          = 180
  layers = [
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-numpy:11",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pandas:15",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-requests:12",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-beautifulsoup4:5",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pyyaml:1"
  ]
}

data "archive_file" "test_odds" {
  type        = "zip"
  source_dir  = "${path.module}/script/scrape_odds"
  output_path = "${path.module}/script/scrape_odds/scraping.zip"
}

resource "aws_lambda_function" "test_odds" {
  function_name    = "scrape_odds"
  filename         = data.archive_file.test_odds.output_path
  source_code_hash = data.archive_file.test_odds.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "scrape_odds.lambda_handler"
  timeout          = 180
  layers = [
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-numpy:11",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pandas:15",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-requests:12",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-beautifulsoup4:5"
  ]
}
