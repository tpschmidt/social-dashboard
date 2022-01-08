resource "aws_cloudwatch_log_group" "main" {
  for_each          = aws_lambda_function.main
  name              = "/aws/lambda/${each.value.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "crawler" {
  name                = "${local.prefix}-crawler"
  schedule_expression = "rate(15 minutes)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "crawler" {
  rule      = aws_cloudwatch_event_rule.crawler.name
  target_id = "RunTheLambda"
  arn       = aws_lambda_function.main["social-crawler"].arn
}

resource "aws_cloudwatch_event_rule" "aggregator" {
  name                = "${local.prefix}-aggregator"
  schedule_expression = "rate(24 hours)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "aggregator" {
  rule      = aws_cloudwatch_event_rule.aggregator.name
  target_id = "RunTheLambda"
  arn       = aws_lambda_function.main["social-aggregator"].arn
}