provider "aws" {
    region = "us-east-1"
    profile = "default"
    assume_role {
        role_arn = "arn:aws:iam::ACCOUNT_ID_HERE:user/USER_NAME_HERE"
    }
}

module "example-web-s3-mod" {
    source = "../"

    web_s3_bucket_name = "example-web-s3-bucket"
    logging_bucket_name = "example-logging-bucket"
    cloudfront_distribution_origin_id = "example-cf-dist-origin-id"
    acm_certificate_domain_name = "example.mydomain.com"
}