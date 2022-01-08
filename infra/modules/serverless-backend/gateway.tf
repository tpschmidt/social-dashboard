resource "aws_apigatewayv2_api" "rest_api" {
  name          = local.prefix
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins     = ["*"]
    allow_headers     = ["*"]
    allow_methods     = ["POST", "GET", "PATCH", "PUT", "DELETE", "HEAD", "OPTIONS"]
    expose_headers    = ["*"]
    max_age           = 0
  }
}

resource "aws_apigatewayv2_route" "get_mapping" {
  api_id             = aws_apigatewayv2_api.rest_api.id
  route_key          = "GET /{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.rest_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.rest_api.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  description          = "Lambda Integration"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.main["social-api"].invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_api_mapping" "mapping" {
  count       = local.has_domain ? 1 : 0
  api_id      = aws_apigatewayv2_api.rest_api.id
  domain_name = aws_apigatewayv2_domain_name.api_gateway_domain[0].id
  stage       = aws_apigatewayv2_stage.stage.id
}

resource "aws_apigatewayv2_domain_name" "api_gateway_domain" {
  count       = local.has_domain ? 1 : 0
  domain_name = "${var.subdomain}.${var.domain}"
  domain_name_configuration {
    certificate_arn = data.aws_acm_certificate.main[0].arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

