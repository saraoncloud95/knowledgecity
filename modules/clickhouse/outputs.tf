output "endpoint" {
  description = "ClickHouse endpoint"
  value       = aws_lb.clickhouse.dns_name
}

output "port" {
  description = "ClickHouse port"
  value       = 8123
}

output "cluster_name" {
  description = "ClickHouse ECS cluster name"
  value       = aws_ecs_cluster.clickhouse.name
}

output "service_name" {
  description = "ClickHouse ECS service name"
  value       = aws_ecs_service.clickhouse.name
}

output "task_definition_arn" {
  description = "ClickHouse task definition ARN"
  value       = aws_ecs_task_definition.clickhouse.arn
}

output "load_balancer_arn" {
  description = "ClickHouse load balancer ARN"
  value       = aws_lb.clickhouse.arn
}

output "target_group_arn" {
  description = "ClickHouse target group ARN"
  value       = aws_lb_target_group.clickhouse.arn
}

output "efs_file_system_id" {
  description = "ClickHouse EFS file system ID"
  value       = aws_efs_file_system.clickhouse.id
}

output "log_group_name" {
  description = "ClickHouse CloudWatch log group name"
  value       = aws_cloudwatch_log_group.clickhouse.name
} 