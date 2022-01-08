data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 3.49.0"
      configuration_aliases = [aws.us-east-1]
    }
  }
}
