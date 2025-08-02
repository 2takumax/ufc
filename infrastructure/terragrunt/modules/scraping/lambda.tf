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

# Fighter scraping - Coordinator
resource "aws_lambda_function" "fighters_coordinator" {
  function_name    = "${var.env}-scrape_fighters_coordinator"
  filename         = data.archive_file.scrape_script.output_path
  source_code_hash = data.archive_file.scrape_script.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "scrape_fighters_coordinator.lambda_handler"
  timeout          = 300  # 5 minutes for coordination
  memory_size      = 512
  environment {
    variables = {
      WORKER_FUNCTION_NAME = "${var.env}-scrape_fighters_worker"
      BATCH_SIZE          = "50"
      MAX_WORKERS         = "10"
    }
  }
  layers = [
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-requests:12",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-beautifulsoup4:5"
  ]
}

# Fighter scraping - Worker
resource "aws_lambda_function" "fighters_worker" {
  function_name    = "${var.env}-scrape_fighters_worker"
  filename         = data.archive_file.scrape_script.output_path
  source_code_hash = data.archive_file.scrape_script.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "scrape_fighters_worker.lambda_handler"
  timeout          = 900  # 15 minutes max
  memory_size      = 1024
  reserved_concurrent_executions = 10  # Limit concurrent executions
  environment {
    variables = {
      BUCKET_NAME    = aws_s3_bucket.lambda_bucket.id
      OUTPUT_PREFIX  = "fighters/raw/"
    }
  }
  layers = [
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-numpy:11",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-pandas:15",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-requests:12",
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-p312-beautifulsoup4:5"
  ]
}
