# VPC Outputs
output "primary_vpc_id" {
  description = "Primary VPC ID"
  value       = module.vpc_primary.vpc_id
}

output "secondary_vpc_id" {
  description = "Secondary VPC ID"
  value       = module.vpc_secondary.vpc_id
}

# EKS Outputs
output "primary_eks_cluster_endpoint" {
  description = "Primary EKS cluster endpoint"
  value       = module.eks_primary.cluster_endpoint
}

output "secondary_eks_cluster_endpoint" {
  description = "Secondary EKS cluster endpoint"
  value       = module.eks_secondary.cluster_endpoint
}

output "primary_eks_cluster_name" {
  description = "Primary EKS cluster name"
  value       = module.eks_primary.cluster_name
}

output "secondary_eks_cluster_name" {
  description = "Secondary EKS cluster name"
  value       = module.eks_secondary.cluster_name
}

# RDS Outputs
output "primary_rds_endpoint" {
  description = "Primary RDS endpoint"
  value       = module.rds_primary.endpoint
  sensitive   = true
}

output "secondary_rds_endpoint" {
  description = "Secondary RDS endpoint"
  value       = module.rds_secondary.endpoint
  sensitive   = true
}

# ClickHouse Outputs
output "clickhouse_endpoint" {
  description = "ClickHouse cluster endpoint"
  value       = module.clickhouse.endpoint
  sensitive   = true
}

# Storage Outputs
output "global_content_bucket" {
  description = "Global content S3 bucket name"
  value       = module.storage.global_content_bucket
}

output "video_storage_bucket" {
  description = "Video storage S3 bucket name"
  value       = module.storage.video_storage_bucket
}

output "user_data_bucket" {
  description = "User data S3 bucket name"
  value       = module.storage.user_data_bucket
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = module.cloudfront.domain_name
}

# ALB Outputs
output "primary_alb_dns_name" {
  description = "Primary ALB DNS name"
  value       = module.alb_primary.alb_dns_name
}

output "secondary_alb_dns_name" {
  description = "Secondary ALB DNS name"
  value       = module.alb_secondary.alb_dns_name
}

# Route53 Outputs
output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = module.route53.zone_id
}

output "route53_name_servers" {
  description = "Route53 name servers"
  value       = module.route53.name_servers
}

# Monitoring Outputs
output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = module.monitoring.grafana_url
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = module.monitoring.prometheus_url
}

# Security Outputs
output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = module.security.waf_web_acl_id
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = module.security.waf_web_acl_arn
}

# Application URLs
output "application_url" {
  description = "Main application URL"
  value       = "https://${var.domain_name}"
}

output "api_url" {
  description = "API endpoint URL"
  value       = "https://api.${var.domain_name}"
}

output "cdn_url" {
  description = "CDN URL for static content"
  value       = "https://${module.cloudfront.domain_name}"
} 