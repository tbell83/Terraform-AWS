# Main vars for web s3 module
variable "web_s3_bucket_name" {
  type        = string
  default     = ""
  description = "Name of the bucket hosting the static website"
}

variable "logging_bucket_name" {
  type        = string
  default     = ""
  description = "Name of the bucket that holds access logs for the web s3 bucket"
}

variable "cloudfront_distribution_origin_id" {
  type        = string
  default     = ""
  description = "origin identifier for cloudfront distribution web s3 bucket"
}

variable "acm_certificate_domain_name" {
  type        = string
  default     = ""
  description = "domain name for the certificate of the website"
}