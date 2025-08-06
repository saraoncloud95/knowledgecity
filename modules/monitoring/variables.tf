variable "environment" {
  description = "Environment name"
  type        = string
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
}

variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for monitoring services"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for monitoring services"
  type        = list(string)
}

variable "grafana_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "changeme123!"
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