variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "primary_alb_dns" {
  description = "Primary ALB DNS name"
  type        = string
}

variable "secondary_alb_dns" {
  description = "Secondary ALB DNS name"
  type        = string
}

variable "primary_alb_zone_id" {
  description = "Primary ALB zone ID"
  type        = string
}

variable "secondary_alb_zone_id" {
  description = "Secondary ALB zone ID"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
  default     = ""
}

variable "cloudfront_zone_id" {
  description = "CloudFront distribution zone ID"
  type        = string
  default     = "Z2FDTNDATAQYW2" # CloudFront's fixed zone ID
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
}

variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
}

variable "alarm_actions" {
  description = "List of ARNs for CloudWatch alarm actions"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
} 