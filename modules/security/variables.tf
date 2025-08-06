variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "alb_arn" {
  description = "ALB ARN for Shield protection"
  type        = string
  default     = ""
}

variable "enable_shield_advanced" {
  description = "Enable AWS Shield Advanced"
  type        = bool
  default     = false
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