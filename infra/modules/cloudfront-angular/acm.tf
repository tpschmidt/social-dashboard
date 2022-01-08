data "aws_acm_certificate" "main" {
  count    = local.has_domain ? 1 : 0
  domain   = var.domain
  provider = aws.us-east-1
}

# if there's no domain, we want to export the execute-api domain name
# to our frontend
resource "null_resource" "export_domain_name" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 3 && ./${local.root}/go.sh set-config-param terraform_cloudfront_url https://${aws_cloudfront_distribution.cdn.domain_name}"
  }

  depends_on = [aws_cloudfront_distribution.cdn]
}