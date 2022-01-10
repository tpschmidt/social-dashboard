resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  acl = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "CloudFrontAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.main.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.main.bucket}/*",
    ]

    principals {
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
      type = "AWS"
    }
  }
}
