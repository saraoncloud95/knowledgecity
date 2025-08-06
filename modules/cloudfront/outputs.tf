output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.main.arn
}

output "origin_access_identity" {
  description = "CloudFront origin access identity"
  value       = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
}

output "function_arn" {
  description = "CloudFront function ARN"
  value       = aws_cloudfront_function.main.arn
}

output "cache_policy_id" {
  description = "Cache policy ID"
  value       = aws_cloudfront_cache_policy.main.id
}

output "origin_request_policy_id" {
  description = "Origin request policy ID"
  value       = aws_cloudfront_origin_request_policy.main.id
}

output "response_headers_policy_id" {
  description = "Response headers policy ID"
  value       = aws_cloudfront_response_headers_policy.main.id
} 