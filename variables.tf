variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "knowledgecity.com"
}

# Primary Region (US)
variable "primary_region" {
  description = "Primary AWS region (US)"
  type        = string
  default     = "us-east-1"
}

variable "primary_vpc_cidr" {
  description = "CIDR block for primary VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "primary_availability_zones" {
  description = "Availability zones for primary region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "primary_node_groups" {
  description = "EKS node groups configuration for primary region"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
  }))
  default = {
    general = {
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 10
      desired_size   = 3
    }
    video-processing = {
      instance_types = ["c5.2xlarge", "c5.4xlarge"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 5
      desired_size   = 2
    }
  }
}

# Secondary Region (Saudi Arabia)
variable "secondary_region" {
  description = "Secondary AWS region (Saudi Arabia)"
  type        = string
  default     = "me-south-1"
}

variable "secondary_vpc_cidr" {
  description = "CIDR block for secondary VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "secondary_availability_zones" {
  description = "Availability zones for secondary region"
  type        = list(string)
  default     = ["me-south-1a", "me-south-1b"]
}

variable "secondary_node_groups" {
  description = "EKS node groups configuration for secondary region"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
  }))
  default = {
    general = {
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 8
      desired_size   = 2
    }
  }
}

# Database Configuration
variable "database_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r6g.xlarge"
}

variable "database_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "8.0.35"
}

variable "database_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 100
}

variable "database_backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 30
}

# ClickHouse Configuration
variable "clickhouse_instance_type" {
  description = "ClickHouse instance type"
  type        = string
  default     = "r6g.2xlarge"
}

variable "clickhouse_node_count" {
  description = "Number of ClickHouse nodes"
  type        = number
  default     = 3
}

# Storage Configuration
variable "video_storage_class" {
  description = "S3 storage class for video files"
  type        = string
  default     = "STANDARD_IA"
}

variable "content_storage_class" {
  description = "S3 storage class for content files"
  type        = string
  default     = "STANDARD"
}

# Monitoring Configuration
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_metrics" {
  description = "Enable CloudWatch metrics"
  type        = bool
  default     = true
}

# Security Configuration
variable "enable_waf" {
  description = "Enable AWS WAF"
  type        = bool
  default     = true
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection"
  type        = bool
  default     = true
}

# Tags
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
} 