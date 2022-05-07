provider "aws" {
  region = "us-east-1"
}

module "example-web-s3-mod" {
  source = "../"

  web_s3_bucket_name          = "example-web-s3-bucket"
  logging_bucket_name         = "example-logging-bucket"
  acm_certificate_domain_name = "example.mydomain.com"
}
