output "endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "RDS master username"
  value       = aws_db_instance.main.username
}

output "read_replica_endpoint" {
  description = "RDS read replica endpoint"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].endpoint : null
}

output "subnet_group_name" {
  description = "RDS subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "parameter_group_name" {
  description = "RDS parameter group name"
  value       = aws_db_parameter_group.main.name
}

output "option_group_name" {
  description = "RDS option group name"
  value       = aws_db_option_group.main.name
}

output "kms_key_arn" {
  description = "KMS key ARN for RDS encryption"
  value       = aws_kms_key.rds.arn
}

output "monitoring_role_arn" {
  description = "RDS monitoring role ARN"
  value       = aws_iam_role.rds_monitoring.arn
} 