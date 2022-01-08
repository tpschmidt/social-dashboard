data "aws_route53_zone" "zone" {
  count   = local.has_domain ? 1 : 0
  name    = var.domain
}

resource "aws_route53_record" "main" {
  count   = local.has_domain ? 1 : 0
  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api_gateway_domain[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_gateway_domain[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}