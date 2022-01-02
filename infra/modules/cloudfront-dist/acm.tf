data "aws_acm_certificate" "main" {
  count    = local.has_domain ? 1 : 0
  domain   = var.domain
  provider = aws.us-east-1
}

