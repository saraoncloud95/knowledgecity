output "global_content_bucket" {
  description = "Global content S3 bucket name"
  value       = aws_s3_bucket.global_content.bucket
}

output "global_content_bucket_arn" {
  description = "Global content S3 bucket ARN"
  value       = aws_s3_bucket.global_content.arn
}

output "global_content_bucket_domain" {
  description = "Global content S3 bucket domain name"
  value       = aws_s3_bucket.global_content.bucket_regional_domain_name
}

output "video_storage_bucket" {
  description = "Video storage S3 bucket name"
  value       = aws_s3_bucket.video_storage.bucket
}

output "video_storage_bucket_arn" {
  description = "Video storage S3 bucket ARN"
  value       = aws_s3_bucket.video_storage.arn
}

output "user_data_bucket" {
  description = "User data S3 bucket name"
  value       = aws_s3_bucket.user_data.bucket
}

output "user_data_bucket_arn" {
  description = "User data S3 bucket ARN"
  value       = aws_s3_bucket.user_data.arn
}

output "global_content_replica_bucket" {
  description = "Global content replica S3 bucket name"
  value       = aws_s3_bucket.global_content_replica.bucket
}

output "global_content_replica_bucket_arn" {
  description = "Global content replica S3 bucket ARN"
  value       = aws_s3_bucket.global_content_replica.arn
}

output "s3_replication_role_arn" {
  description = "S3 replication IAM role ARN"
  value       = aws_iam_role.s3_replication.arn
} 