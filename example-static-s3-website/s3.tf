### All S3 bucket resources
# WEB S3 bucket resources
resource "aws_s3_bucket" "web_s3_bucket" {
  bucket = var.web_s3_bucket_name
}

resource "aws_s3_bucket_acl" "web_s3_bucket_acl" {
  bucket = aws_s3_bucket.web_s3_bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "web_s3_iam_policy_document" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.web_s3_cloudfront_origin_access_identity.id,
      ]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.web_s3_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "web_s3_bucket_policy" {
  bucket = aws_s3_bucket.web_s3_bucket.id
  policy = data.aws_iam_policy_document.web_s3_iam_policy_document.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web_s3_side_encrption_configuration" {
  bucket = aws_s3_bucket.web_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.web_s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# resource "aws_s3_bucket_website_configuration" "web_s3_website_configuration" {
#   bucket = aws_s3_bucket.web_s3_bucket.bucket

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     suffix = "error.html"
#   }
# }

resource "aws_s3_bucket_versioning" "web_s3_versioning" {
  bucket = aws_s3_bucket.web_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "web_s3_public_access_block" {
  bucket = aws_s3_bucket.web_s3_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_logging" "web_s3_logging" {
  bucket = aws_s3_bucket.web_s3_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "s3/web-s3/"
}

resource "aws_s3_bucket_cors_configuration" "web_s3_cors_configuration" {
  bucket = aws_s3_bucket.web_s3_bucket.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["${var.acm_certificate_domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "web_s3_lifecycle_configuration" {
  bucket     = aws_s3_bucket.web_s3_bucket.bucket
  depends_on = [aws_s3_bucket_versioning.web_s3_versioning]

  rule {
    id     = "non-current-web-s3-versions-rule"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }

}

# Logging bucket resources
resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket_name
}

resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "private"
}

data "aws_iam_policy_document" "logging_bucket_iam_policy_document" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_distribution.web_s3_cloudfront_distribution.id,
        aws_s3_bucket.web_s3_bucket.id,
      ]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*",
    ]
  }
}


resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = aws_s3_bucket.logging_bucket.id
  policy = data.aws_iam_policy_document.logging_bucket_iam_policy_document.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_side_encrption_configuration" {
  bucket = aws_s3_bucket.logging_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logging_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "logging_versioning" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logging_public_access_block" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_logging" "logging_logging" {
  bucket = aws_s3_bucket.logging_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "s3/logging-bucket/"
}

resource "aws_s3_bucket_lifecycle_configuration" "logging_lifecycle_configuration" {
  bucket     = aws_s3_bucket.logging_bucket.bucket
  depends_on = [aws_s3_bucket_versioning.logging_versioning]

  rule {
    id     = "non-current-logging-bucket-versions-rule"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }
  }

}