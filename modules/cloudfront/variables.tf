variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_domain" {
  description = "S3 bucket domain name for origin"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
} 