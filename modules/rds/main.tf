# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  family = "mysql8.0"
  name   = "${var.identifier}-parameter-group"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "max_connections"
    value = "1000"
  }

  tags = var.common_tags
}

# RDS Option Group
resource "aws_db_option_group" "main" {
  engine_name              = "mysql"
  major_engine_version     = "8.0"
  name                     = "${var.identifier}-option-group"
  option_group_description = "Option group for ${var.identifier}"

  tags = var.common_tags
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = var.identifier

  # Engine Configuration
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id           = aws_kms_key.rds.arn

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false
  port                   = 3306

  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Backup Configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot  = true

  # High Availability
  multi_az               = true
  deletion_protection    = var.deletion_protection
  skip_final_snapshot    = false
  final_snapshot_identifier = "${var.identifier}-final-snapshot"

  # Performance Insights
  performance_insights_enabled          = false
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_monitoring.arn

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.main.name
  option_group_name    = aws_db_option_group.main.name

  # Logging
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  tags = var.common_tags
}

# KMS Key for RDS Encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.common_tags, {
    Name = "${var.identifier}-rds-kms-key"
  })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.identifier}-rds-key"
  target_key_id = aws_kms_key.rds.key_id
}

# IAM Role for RDS Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.identifier}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# RDS Read Replica (for read scaling)
resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier = "${var.identifier}-read-replica"

  # Engine Configuration
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.read_replica_instance_class

  # Storage Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id           = aws_kms_key.rds.arn

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false
  port                   = 3306

  # Replica Configuration
  replicate_source_db = aws_db_instance.main.arn
  backup_retention_period = 0
  skip_final_snapshot    = true

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_monitoring.arn

  tags = merge(var.common_tags, {
    Name = "${var.identifier}-read-replica"
  })
}

# CloudWatch Alarms for RDS
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.identifier}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  alarm_name          = "${var.identifier}-free-storage-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000000000" # 1GB in bytes
  alarm_description   = "This metric monitors RDS free storage space"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  alarm_name          = "${var.identifier}-database-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "800"
  alarm_description   = "This metric monitors RDS database connections"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  tags = var.common_tags
} 