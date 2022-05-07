# Cloudfront distribution settings
resource "aws_cloudfront_distribution" "web_s3_cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.web_s3_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.web_s3_bucket.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web_s3_cloudfront_origin_access_identity.cloudfront_access_identity_path
    }
  }

  aliases = [
    "${var.acm_certificate_domain_name}",
    "www.${var.acm_certificate_domain_name}"
  ]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "web s3 cloudfront distribution"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.web_s3_bucket.bucket}.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.web_s3_bucket.bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = [
        "US"
      ]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.web_s3_cf_certificate.arn
  }
}

resource "aws_cloudfront_origin_access_identity" "web_s3_cloudfront_origin_access_identity" {
  comment = "web s3 OAI to access bucket"
}