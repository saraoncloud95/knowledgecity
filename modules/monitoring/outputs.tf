output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_lb.monitoring.dns_name}/prometheus"
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://${aws_lb.monitoring.dns_name}"
}

output "monitoring_alb_dns" {
  description = "Monitoring ALB DNS name"
  value       = aws_lb.monitoring.dns_name
}

output "prometheus_target_group_arn" {
  description = "Prometheus target group ARN"
  value       = aws_lb_target_group.prometheus.arn
}

output "grafana_target_group_arn" {
  description = "Grafana target group ARN"
  value       = aws_lb_target_group.grafana.arn
}

output "monitoring_efs_id" {
  description = "Monitoring EFS file system ID"
  value       = aws_efs_file_system.monitoring.id
}

output "prometheus_log_group" {
  description = "Prometheus CloudWatch log group name"
  value       = aws_cloudwatch_log_group.prometheus.name
}

output "grafana_log_group" {
  description = "Grafana CloudWatch log group name"
  value       = aws_cloudwatch_log_group.grafana.name
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
} 