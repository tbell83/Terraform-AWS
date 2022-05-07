resource "aws_kms_key" "web_s3_kms_key" {
  description             = "web s3 kms key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "logging_kms_key" {
  description             = "web s3 kms key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
