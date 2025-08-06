# ECS Cluster for Monitoring Stack
resource "aws_ecs_cluster" "monitoring" {
  name = "${var.environment}-monitoring-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.common_tags
}

# Prometheus Task Definition
resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.environment}-prometheus-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "prometheus"
      image = "prom/prometheus:latest"
      
      portMappings = [
        {
          containerPort = 9090
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "PROMETHEUS_CONFIG"
          value = "prometheus.yml"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "prometheus-config"
          containerPath = "/etc/prometheus"
          readOnly      = true
        },
        {
          sourceVolume  = "prometheus-data"
          containerPath = "/prometheus"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.prometheus.name
          awslogs-region        = var.primary_region
          awslogs-stream-prefix = "prometheus"
        }
      }
    }
  ])

  volume {
    name = "prometheus-config"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.monitoring.id
      root_directory = "/prometheus-config"
    }
  }

  volume {
    name = "prometheus-data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.monitoring.id
      root_directory = "/prometheus-data"
    }
  }

  tags = var.common_tags
}

# Grafana Task Definition
resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.environment}-grafana-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = "grafana/grafana:latest"
      
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "GF_SECURITY_ADMIN_PASSWORD"
          value = var.grafana_password
        },
        {
          name  = "GF_INSTALL_PLUGINS"
          value = "grafana-cloudwatch-datasource,grafana-piechart-panel"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "grafana-data"
          containerPath = "/var/lib/grafana"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana.name
          awslogs-region        = var.primary_region
          awslogs-stream-prefix = "grafana"
        }
      }
    }
  ])

  volume {
    name = "grafana-data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.monitoring.id
      root_directory = "/grafana-data"
    }
  }

  tags = var.common_tags
}

# ECS Services
resource "aws_ecs_service" "prometheus" {
  name            = "${var.environment}-prometheus-service"
  cluster         = aws_ecs_cluster.monitoring.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prometheus.arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  depends_on = [aws_lb_listener.monitoring]

  tags = var.common_tags
}

resource "aws_ecs_service" "grafana" {
  name            = "${var.environment}-grafana-service"
  cluster         = aws_ecs_cluster.monitoring.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.monitoring]

  tags = var.common_tags
}

# Application Load Balancer for Monitoring
resource "aws_lb" "monitoring" {
  name               = "${var.environment}-monitoring-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = var.common_tags
}

# Target Groups
resource "aws_lb_target_group" "prometheus" {
  name        = "${var.environment}-prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = data.aws_subnet.selected.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/-/healthy"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = var.common_tags
}

resource "aws_lb_target_group" "grafana" {
  name        = "${var.environment}-grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.aws_subnet.selected.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = var.common_tags
}

# Load Balancer Listener
resource "aws_lb_listener" "monitoring" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

# Listener Rules
resource "aws_lb_listener_rule" "prometheus" {
  listener_arn = aws_lb_listener.monitoring.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }

  condition {
    path_pattern {
      values = ["/prometheus*"]
    }
  }
}

# EFS File System for Monitoring Data
resource "aws_efs_file_system" "monitoring" {
  creation_token = "${var.environment}-monitoring-efs"
  encrypted       = true

  tags = merge(var.common_tags, {
    Name = "${var.environment}-monitoring-efs"
  })
}

# EFS Mount Targets
resource "aws_efs_mount_target" "monitoring" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.monitoring.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = var.security_group_ids
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "prometheus" {
  name              = "/ecs/${var.environment}-prometheus"
  retention_in_days = 30

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/${var.environment}-grafana"
  retention_in_days = 30

  tags = var.common_tags
}

# IAM Roles
resource "aws_iam_role" "ecs_execution" {
  name = "${var.environment}-monitoring-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.environment}-monitoring-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy for CloudWatch Access
resource "aws_iam_role_policy" "cloudwatch_access" {
  name = "${var.environment}-monitoring-cloudwatch-access"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Data source for subnet VPC ID
data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-monitoring-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.prometheus.name, "ClusterName", aws_ecs_cluster.monitoring.name],
            ["AWS/ECS", "MemoryUtilization", "ServiceName", aws_ecs_service.prometheus.name, "ClusterName", aws_ecs_cluster.monitoring.name],
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.grafana.name, "ClusterName", aws_ecs_cluster.monitoring.name],
            ["AWS/ECS", "MemoryUtilization", "ServiceName", aws_ecs_service.grafana.name, "ClusterName", aws_ecs_cluster.monitoring.name]
          ]
          period = 300
          stat   = "Average"
          region = var.primary_region
          title  = "ECS Service Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.monitoring.arn_suffix],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.monitoring.arn_suffix]
          ]
          period = 300
          stat   = "Sum"
          region = var.primary_region
          title  = "Load Balancer Metrics"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "prometheus_cpu" {
  alarm_name          = "${var.environment}-prometheus-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors Prometheus CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = aws_ecs_cluster.monitoring.name
    ServiceName = aws_ecs_service.prometheus.name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "grafana_cpu" {
  alarm_name          = "${var.environment}-grafana-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors Grafana CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = aws_ecs_cluster.monitoring.name
    ServiceName = aws_ecs_service.grafana.name
  }

  tags = var.common_tags
} 