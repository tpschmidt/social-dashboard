data "aws_acm_certificate" "main" {
  count    = local.has_domain ? 1 : 0
  domain   = var.domain
}

# if there's no domain, we want to export the execute-api domain name
# to our frontend
resource "null_resource" "export_domain_name" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "./${local.root}/go.sh set-backend-url ${aws_apigatewayv2_stage.stage.invoke_url}"
  }

  depends_on = [aws_apigatewayv2_stage.stage]
}