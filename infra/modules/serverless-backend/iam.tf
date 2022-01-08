resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvokeStage"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main["social-api"].arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.rest_api.execution_arn}/*"
}

resource "aws_iam_role" "main" {
  name               = local.prefix
  assume_role_policy = data.aws_iam_policy_document.principal.json
}

data "aws_iam_policy_document" "principal" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    effect  = "Allow"
  }
}

data "aws_iam_policy_document" "main" {
  version = "2012-10-17"
  statement {
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }

  statement {
    actions   = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    resources = [aws_dynamodb_table.platform_data.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "main" {
  name   = local.prefix
  path   = "/"
  policy = data.aws_iam_policy_document.main.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}
