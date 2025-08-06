output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = aws_wafv2_web_acl.main.id
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_name" {
  description = "WAF Web ACL name"
  value       = aws_wafv2_web_acl.main.name
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.main.id
}

output "guardduty_findings_bucket" {
  description = "GuardDuty findings S3 bucket name"
  value       = aws_s3_bucket.guardduty_findings.bucket
}

output "waf_logs_bucket" {
  description = "WAF logs S3 bucket name"
  value       = aws_s3_bucket.waf_logs.bucket
}

output "firehose_delivery_stream_arn" {
  description = "Kinesis Firehose delivery stream ARN"
  value       = aws_kinesis_firehose_delivery_stream.waf_logs.arn
}

output "guardduty_kms_key_arn" {
  description = "GuardDuty KMS key ARN"
  value       = aws_kms_key.guardduty.arn
} 