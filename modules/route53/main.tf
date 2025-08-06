# Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = var.common_tags
}

# Health Checks
resource "aws_route53_health_check" "primary" {
  fqdn              = var.primary_alb_dns
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = merge(var.common_tags, {
    Name = "${var.domain_name}-primary-health-check"
  })
}

resource "aws_route53_health_check" "secondary" {
  fqdn              = var.secondary_alb_dns
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = merge(var.common_tags, {
    Name = "${var.domain_name}-secondary-health-check"
  })
}

# A Record for Primary Region
resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.primary_alb_dns
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }

  set_identifier = "primary"
  health_check_id = aws_route53_health_check.primary.id

  failover_routing_policy {
    type = "PRIMARY"
  }
}

# A Record for Secondary Region (Failover)
resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.secondary_alb_dns
    zone_id                = var.secondary_alb_zone_id
    evaluate_target_health = true
  }

  set_identifier = "secondary"
  health_check_id = aws_route53_health_check.secondary.id

  failover_routing_policy {
    type = "SECONDARY"
  }
}

# API Subdomain
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.primary_alb_dns
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }
}

# CDN Subdomain
resource "aws_route53_record" "cdn" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "cdn.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

# Regional Subdomains
resource "aws_route53_record" "us" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "us.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.primary_alb_dns
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "sa" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "sa.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.secondary_alb_dns
    zone_id                = var.secondary_alb_zone_id
    evaluate_target_health = true
  }
}

# MX Record for Email
resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = "300"

  records = [
    "10 mail.${var.domain_name}."
  ]
}

# TXT Record for SPF
resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = "300"

  records = [
    "v=spf1 include:_spf.google.com ~all"
  ]
}

# CNAME Records for Subdomains
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"

  records = [var.domain_name]
}

# Monitoring and Analytics Subdomains
resource "aws_route53_record" "monitoring" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "monitoring.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.primary_alb_dns
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }
}

# CloudWatch Alarms for Route53 Health Checks
resource "aws_cloudwatch_metric_alarm" "primary_health_check" {
  alarm_name          = "${var.domain_name}-primary-health-check"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors primary region health check"
  alarm_actions       = var.alarm_actions

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary.id
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "secondary_health_check" {
  alarm_name          = "${var.domain_name}-secondary-health-check"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors secondary region health check"
  alarm_actions       = var.alarm_actions

  dimensions = {
    HealthCheckId = aws_route53_health_check.secondary.id
  }

  tags = var.common_tags
} 