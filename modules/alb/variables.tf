variable "name" {
  description = "Name of the ALB"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ALB"
  type        = list(string)
}

variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
  default     = "knowledgecity.com"
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for certificate validation"
  type        = string
  default     = ""
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