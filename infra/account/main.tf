terraform {
  required_version = "=1.0.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49.0"
    }
  }

  backend "s3" {
    bucket         = "$BACKEND_BUCKET"
    dynamodb_table = "$BACKEND_LOCK_TABLE"
    key            = "social-dashboard/prod.tfstate"
    region         = "eu-central-1"
  }
}

provider "aws" {
  region              = local.region
  allowed_account_ids = [local.account_id]
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

module "cloudfront" {
  source      = "../modules/cloudfront-dist"
  subdomain   = local.subdomain
  dist_prefix = "social-dashboard"
  domain      = local.domain_name
  bucket_name = local.dist_bucket
  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}