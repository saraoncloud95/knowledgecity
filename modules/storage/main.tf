# Global Content Bucket (for educational courses)
resource "aws_s3_bucket" "global_content" {
  bucket = "${var.environment}-knowledgecity-global-content-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "Global Content Storage"
    Purpose = "Educational courses and global content"
  })
}

# Video Storage Bucket
resource "aws_s3_bucket" "video_storage" {
  bucket = "${var.environment}-knowledgecity-video-storage-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "Video Storage"
    Purpose = "Raw and processed video files"
  })
}

# User Data Bucket (region-specific)
resource "aws_s3_bucket" "user_data" {
  bucket = "${var.environment}-knowledgecity-user-data-${var.primary_region}-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "User Data Storage"
    Purpose = "User-specific data and files"
    Region = var.primary_region
  })
}

# Random string for bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Bucket Versioning
resource "aws_s3_bucket_versioning" "global_content" {
  bucket = aws_s3_bucket.global_content.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "user_data" {
  bucket = aws_s3_bucket.user_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "global_content" {
  bucket = aws_s3_bucket.global_content.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "user_data" {
  bucket = aws_s3_bucket.user_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "global_content" {
  bucket = aws_s3_bucket.global_content.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "user_data" {
  bucket = aws_s3_bucket.user_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle Policies
resource "aws_s3_bucket_lifecycle_configuration" "global_content" {
  bucket = aws_s3_bucket.global_content.id

  rule {
    id     = "global_content_lifecycle"
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

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 2555 # 7 years
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  rule {
    id     = "video_storage_lifecycle"
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

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 1825 # 5 years
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "user_data" {
  bucket = aws_s3_bucket.user_data.id

  rule {
    id     = "user_data_lifecycle"
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
      days = 1095 # 3 years
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

# Bucket Policies
resource "aws_s3_bucket_policy" "global_content" {
  bucket = aws_s3_bucket.global_content.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.global_content.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::*:distribution/*"
          }
        }
      }
    ]
  })
}

# CORS Configuration for Video Storage
resource "aws_s3_bucket_cors_configuration" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Inventory Configuration
resource "aws_s3_bucket_inventory" "global_content" {
  bucket = aws_s3_bucket.global_content.id
  name   = "global-content-inventory"

  included_object_versions = "All"

  schedule {
    frequency = "Weekly"
  }

  destination {
    bucket {
      format     = "ORC"
      bucket_arn = aws_s3_bucket.global_content.arn
      prefix     = "inventory/"
    }
  }
}

# Replication Configuration for Global Content
resource "aws_s3_bucket_replication_configuration" "global_content" {
  depends_on = [aws_s3_bucket_versioning.global_content]

  role   = aws_iam_role.s3_replication.arn
  bucket = aws_s3_bucket.global_content.id

  rule {
    id     = "global_content_replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.global_content_replica.arn
      storage_class = "STANDARD"
    }

    filter {
      prefix = "courses/"
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }
}

# Replica Bucket for Global Content
resource "aws_s3_bucket" "global_content_replica" {
  provider = aws.secondary
  bucket   = "${var.environment}-knowledgecity-global-content-replica-${var.secondary_region}-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "Global Content Replica"
    Purpose = "Replica of global content for secondary region"
    Region = var.secondary_region
  })
}

# S3 Bucket Versioning for Replica Bucket
resource "aws_s3_bucket_versioning" "global_content_replica" {
  provider = aws.secondary
  bucket = aws_s3_bucket.global_content_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAM Role for S3 Replication
resource "aws_iam_role" "s3_replication" {
  name = "${var.environment}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "s3_replication" {
  name = "${var.environment}-s3-replication-policy"
  role = aws_iam_role.s3_replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.global_content.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.global_content.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${aws_s3_bucket.global_content_replica.arn}/*"
      }
    ]
  })
} 