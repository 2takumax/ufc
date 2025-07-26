data "archive_file" "scrape_script" {
  type        = "zip"
  source_dir  = "${path.module}/script"
  output_path = "${path.module}/script/scraping.zip"
}

resource "aws_lambda_function" "events" {
  function_name    = "scrape_events"
  filename         = data.archive_file.scrape_script.output_path
  source_code_hash = data.archive_file.scrape_script.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "scrape_events_lambda.lambda_handler"
  timeout          = 180
  layers = [
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-numpy:11",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pandas:15",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-requests:12",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-beautifulsoup4:5",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pyyaml:1"
  ]
}

resource "aws_lambda_function" "odds" {
  function_name    = "scrape_odds"
  filename         = data.archive_file.scrape_script.output_path
  source_code_hash = data.archive_file.scrape_script.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "scrape_odds_lambda.lambda_handler"
  timeout          = 900
  layers = [
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-numpy:11",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pandas:15",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-requests:12",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-beautifulsoup4:5"
  ]
}
