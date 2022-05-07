# Certificate for cloudfront distribution for web s3
resource "aws_acm_certificate" "web_s3_cf_certificate" {
    domain_name = module.example-web-s3-mod.acm_certificate_domain_name
    validation_method = "EMAIL"

    lifecycle {
        create_before_destroy = true
    }
}