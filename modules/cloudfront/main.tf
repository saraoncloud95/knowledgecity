# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_All"

  # Origin Configuration
  origin {
    domain_name = var.s3_bucket_domain
    origin_id   = "S3-${var.environment}-global-content"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  # Default Cache Behavior
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.environment}-global-content"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    # Response Headers Policy
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id

    # Function Associations
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.main.arn
    }
  }

  # Cache Behavior for Video Content
  ordered_cache_behavior {
    path_pattern     = "/videos/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.environment}-global-content"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400  # 24 hours for video content
    max_ttl                = 604800 # 7 days

    # Response Headers Policy
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
  }

  # Cache Behavior for API
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.environment}-global-content"

    forwarded_values {
      query_string = true
      headers      = ["Content-Type", "X-Requested-With"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0  # No caching for API
    max_ttl                = 0

    # Response Headers Policy
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
  }

  # Error Pages
  custom_error_response {
    error_code         = 404
    response_code      = "200"
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = "200"
    response_page_path = "/index.html"
  }

  # Geographic Restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Viewer Certificate
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  # Logging
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix          = "cloudfront-logs/"
  }

  tags = var.common_tags
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "OAI for ${var.environment} global content"
}

# Cache Policy
resource "aws_cloudfront_cache_policy" "main" {
  name        = "${var.environment}-cache-policy"
  comment     = "Cache policy for ${var.environment}"
  default_ttl = 3600
  max_ttl     = 86400
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

# Cache Policy for Video
resource "aws_cloudfront_cache_policy" "video" {
  name        = "${var.environment}-video-cache-policy"
  comment     = "Cache policy for video content"
  default_ttl = 86400
  max_ttl     = 604800
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

# Origin Request Policy
resource "aws_cloudfront_origin_request_policy" "main" {
  name    = "${var.environment}-origin-request-policy"
  comment = "Origin request policy for ${var.environment}"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}

# Origin Request Policy for API
resource "aws_cloudfront_origin_request_policy" "api" {
  name    = "${var.environment}-api-origin-request-policy"
  comment = "Origin request policy for API"

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Content-Type", "X-Requested-With"]
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

# Response Headers Policy
resource "aws_cloudfront_response_headers_policy" "main" {
  name    = "${var.environment}-response-headers-policy"
  comment = "Response headers policy for ${var.environment}"

  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
    }
  }

  cors_config {
    access_control_allow_credentials = false
    access_control_allow_headers {
      items = ["*"]
    }
    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS"]
    }
    access_control_allow_origins {
      items = ["*"]
    }
    access_control_expose_headers {
      items = ["ETag"]
    }
    access_control_max_age_sec = 600
    origin_override            = true
  }
}

# CloudFront Function
resource "aws_cloudfront_function" "main" {
  name    = "${var.environment}-function"
  runtime = "cloudfront-js-1.0"
  comment = "Function for ${var.environment}"
  publish = true
  code    = file("${path.module}/function.js")
}

# S3 Bucket for CloudFront Logs
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.environment}-knowledgecity-cloudfront-logs-${random_string.bucket_suffix.result}"

  tags = merge(var.common_tags, {
    Name = "CloudFront Logs"
  })
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Versioning for Logs
resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption for Logs
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block for Logs
resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle for Logs
resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    id     = "cloudfront_logs_lifecycle"
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