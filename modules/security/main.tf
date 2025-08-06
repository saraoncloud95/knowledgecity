# WAF Web ACL - Simplified
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.environment}-web-acl"
  description = "WAF Web ACL for ${var.environment}"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = var.common_tags
}

# WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}

# Data source for current region
data "aws_region" "current" {}

# Kinesis Firehose for WAF Logs
resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
  name        = "${var.environment}-waf-logs"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.waf_logs.arn
    prefix     = "waf-logs/"
  }

  tags = var.common_tags
}

# S3 Bucket for WAF Logs
resource "aws_s3_bucket" "waf_logs" {
  bucket = "${var.environment}-knowledgecity-waf-logs-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "WAF Logs"
  })
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Versioning for WAF Logs
resource "aws_s3_bucket_versioning" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption for WAF Logs
resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block for WAF Logs
resource "aws_s3_bucket_public_access_block" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle for WAF Logs
resource "aws_s3_bucket_lifecycle_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    id     = "waf_logs_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 2555 # 7 years
    }
  }
}

# IAM Role for Firehose
resource "aws_iam_role" "firehose_role" {
  name = "${var.environment}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "firehose_policy" {
  name = "${var.environment}-firehose-policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.waf_logs.arn,
          "${aws_s3_bucket.waf_logs.arn}/*"
        ]
      }
    ]
  })
}

# AWS Shield Advanced (Optional - for DDoS protection)
resource "aws_shield_protection" "alb" {
  count        = var.enable_shield_advanced ? 1 : 0
  name         = "${var.environment}-alb-protection"
  resource_arn = var.alb_arn

  tags = var.common_tags
}

# CloudWatch Alarms for WAF
resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  alarm_name          = "${var.environment}-waf-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors WAF blocked requests"
  alarm_actions       = var.alarm_actions

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.primary_region
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "waf_allowed_requests" {
  alarm_name          = "${var.environment}-waf-allowed-requests"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "AllowedRequests"
  namespace           = "AWS/WAFV2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors WAF allowed requests"
  alarm_actions       = var.alarm_actions

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.primary_region
  }

  tags = var.common_tags
}

# GuardDuty (for threat detection)
resource "aws_guardduty_detector" "main" {
  enable = true

  tags = var.common_tags
}

# GuardDuty Findings Bucket
resource "aws_s3_bucket" "guardduty_findings" {
  bucket = "${var.environment}-knowledgecity-guardduty-findings-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "GuardDuty Findings"
  })
}

# S3 Bucket Versioning for GuardDuty Findings
resource "aws_s3_bucket_versioning" "guardduty_findings" {
  bucket = aws_s3_bucket.guardduty_findings.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption for GuardDuty Findings
resource "aws_s3_bucket_server_side_encryption_configuration" "guardduty_findings" {
  bucket = aws_s3_bucket.guardduty_findings.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block for GuardDuty Findings
resource "aws_s3_bucket_public_access_block" "guardduty_findings" {
  bucket = aws_s3_bucket.guardduty_findings.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy for GuardDuty Findings
resource "aws_s3_bucket_policy" "guardduty_findings" {
  bucket = aws_s3_bucket.guardduty_findings.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.guardduty_findings.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action = [
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.guardduty_findings.arn
      }
    ]
  })
}

# GuardDuty Publishing Destination
resource "aws_guardduty_publishing_destination" "main" {
  detector_id     = aws_guardduty_detector.main.id
  destination_arn = aws_s3_bucket.guardduty_findings.arn
  kms_key_arn     = aws_kms_key.guardduty.arn
}

# KMS Key for GuardDuty
resource "aws_kms_key" "guardduty" {
  description             = "KMS key for GuardDuty"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow GuardDuty to use the key"
        Effect = "Allow"
        Principal = {
          Service = "guardduty.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-guardduty-kms-key"
  })
}

# Data source for current account ID
data "aws_caller_identity" "current" {}

resource "aws_kms_alias" "guardduty" {
  name          = "alias/${var.environment}-guardduty-key"
  target_key_id = aws_kms_key.guardduty.key_id
} 