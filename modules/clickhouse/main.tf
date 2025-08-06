# ClickHouse ECS Cluster
resource "aws_ecs_cluster" "clickhouse" {
  name = "${var.cluster_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.common_tags
}

# ClickHouse Task Definition
resource "aws_ecs_task_definition" "clickhouse" {
  family                   = "${var.cluster_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "clickhouse-server"
      image = "clickhouse/clickhouse-server:latest"
      
      portMappings = [
        {
          containerPort = 9000
          protocol      = "tcp"
        },
        {
          containerPort = 8123
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "CLICKHOUSE_DB"
          value = var.database_name
        },
        {
          name  = "CLICKHOUSE_USER"
          value = var.database_user
        },
        {
          name  = "CLICKHOUSE_PASSWORD"
          value = var.database_password
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.clickhouse.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "clickhouse"
        }
      }

      mountPoints = [
        {
          sourceVolume  = "clickhouse-data"
          containerPath = "/var/lib/clickhouse"
          readOnly      = false
        }
      ]
    }
  ])

  volume {
    name = "clickhouse-data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.clickhouse.id
      root_directory = "/"
    }
  }

  tags = var.common_tags
}

# ECS Service
resource "aws_ecs_service" "clickhouse" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.clickhouse.id
  task_definition = aws_ecs_task_definition.clickhouse.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.clickhouse.arn
    container_name   = "clickhouse-server"
    container_port   = 8123
  }

  depends_on = [aws_lb_listener.clickhouse]

  tags = var.common_tags
}

# Application Load Balancer
resource "aws_lb" "clickhouse" {
  name               = "${var.cluster_name}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = var.common_tags
}

# Target Group
resource "aws_lb_target_group" "clickhouse" {
  name        = "${var.cluster_name}-tg"
  port        = 8123
  protocol    = "HTTP"
  vpc_id      = data.aws_subnet.selected.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/ping"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = var.common_tags
}

# Load Balancer Listener
resource "aws_lb_listener" "clickhouse" {
  load_balancer_arn = aws_lb.clickhouse.arn
  port              = "8123"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clickhouse.arn
  }
}

# EFS File System for ClickHouse Data
resource "aws_efs_file_system" "clickhouse" {
  creation_token = "${var.cluster_name}-efs"
  encrypted       = true

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-efs"
  })
}

# EFS Mount Targets
resource "aws_efs_mount_target" "clickhouse" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.clickhouse.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = var.security_group_ids
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "clickhouse" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = 30

  tags = var.common_tags
}

# IAM Role for ECS Execution
resource "aws_iam_role" "ecs_execution" {
  name = "${var.cluster_name}-ecs-execution-role"

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

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task" {
  name = "${var.cluster_name}-ecs-task-role"

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

# Data source for subnet VPC ID
data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

# CloudWatch Alarms for ClickHouse
resource "aws_cloudwatch_metric_alarm" "clickhouse_cpu" {
  alarm_name          = "${var.cluster_name}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ClickHouse CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = aws_ecs_cluster.clickhouse.name
    ServiceName = aws_ecs_service.clickhouse.name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "clickhouse_memory" {
  alarm_name          = "${var.cluster_name}-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ClickHouse memory utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = aws_ecs_cluster.clickhouse.name
    ServiceName = aws_ecs_service.clickhouse.name
  }

  tags = var.common_tags
} 