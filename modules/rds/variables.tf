variable "identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for RDS"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for RDS"
  type        = list(string)
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r6g.xlarge"
}

variable "engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "8.0.35"
}

variable "allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 100
}

variable "max_allocated_storage" {
  description = "RDS max allocated storage in GB"
  type        = number
  default     = 1000
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "knowledgecity"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "changeme123!"
}

variable "backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 30
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "create_read_replica" {
  description = "Create a read replica"
  type        = bool
  default     = true
}

variable "read_replica_instance_class" {
  description = "Read replica instance class"
  type        = string
  default     = "db.r6g.large"
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