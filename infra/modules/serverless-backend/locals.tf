locals {
  prefix         = "social-dashboard"
  has_domain    = var.domain != ""
  aliases       = local.has_domain ? ["${var.subdomain}.${var.domain}"] : []
  runtime       = "nodejs14.x"
  root          = "${path.module}/../../.."
  config         = "${local.root}/configuration.json"
  function_dir  = "${local.root}/lambda"
  tmp_dir       = "${path.module}/tmp"
  dist_dir      = "${local.root}/dist"
  app_dir       = "${local.root}/app"
  functions     = toset([
    "social-aggregator",
    "social-api",
    "social-crawler"
  ])
}

