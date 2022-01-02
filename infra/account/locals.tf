data "aws_caller_identity" "current" {}

locals {
  region      = "eu-central-1"
  domain_name = jsondecode(file("${path.module}/../../configuration.json")).terraform_domain
  subdomain   = jsondecode(file("${path.module}/../../configuration.json")).terraform_subdomain
  account_id  = jsondecode(file("${path.module}/../../configuration.json")).terraform_account_id
  dist_bucket = jsondecode(file("${path.module}/../../configuration.json")).terraform_dist_bucket
}
