locals {
  prefix      = "social-dashboard"
  has_domain = var.domain != ""
  aliases    = local.has_domain ? ["${var.subdomain}.${var.domain}"] : []
  root       = "${path.module}/../../.."
}