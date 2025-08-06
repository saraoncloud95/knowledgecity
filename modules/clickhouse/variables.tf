variable "cluster_name" {
  description = "ClickHouse cluster name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ClickHouse"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ClickHouse"
  type        = list(string)
}

variable "task_cpu" {
  description = "CPU units for ClickHouse task"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Memory for ClickHouse task in MiB"
  type        = number
  default     = 2048
}

variable "service_desired_count" {
  description = "Desired number of ClickHouse tasks"
  type        = number
  default     = 2
}

variable "database_name" {
  description = "ClickHouse database name"
  type        = string
  default     = "analytics"
}

variable "database_user" {
  description = "ClickHouse database user"
  type        = string
  default     = "default"
}

variable "database_password" {
  description = "ClickHouse database password"
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