resource "aws_dynamodb_table" "platform_data" {
  hash_key         = "platform"
  range_key        = "timestamp"
  name             = "social-platform-data"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  billing_mode     = "PROVISIONED"

  read_capacity  = 3
  write_capacity = 3

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "platform"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

}

