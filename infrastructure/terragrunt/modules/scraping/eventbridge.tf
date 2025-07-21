resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "run-test-terraform-daily"
  description         = "Triggers test_terraform lambda daily at 6AM JST"
  schedule_expression = "cron(0 18 ? * 1 *)" # UTCで前日の21:00 = JST 6:00
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

resource "aws_cloudwatch_event_rule" "odds" {
  name                = "odds"
  description         = "Triggers test_terraform lambda daily at 6AM JST"
  schedule_expression = "cron(0 18 ? * 1 *)" # UTCで前日の21:00 = JST 6:00
}

resource "aws_cloudwatch_event_target" "odds" {
  rule      = aws_cloudwatch_event_rule.odds.name
  target_id = "test_terraform_lambda"
  arn       = aws_lambda_function.odds.arn
}

resource "aws_lambda_permission" "odds" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.odds.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.odds.arn
}
