# S3 Bucket Configuration - SECURITY FIXES APPLIED
# This file has been updated to block public write access as per security requirements
# Public write access (PutObject, DeleteObject) has been blocked

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# S3 Bucket with security fixes applied
resource "aws_s3_bucket" "misconfigured_bucket" {
  bucket = "my-misconfigured-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "SecuredBucket"
    Environment = "SecurityTesting"
    Purpose     = "Public write access blocked - security fix applied"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# SECURITY FIX: Public access block enabled to prevent public write access
# block_public_acls and restrict_public_buckets prevent public write via ACLs
# block_public_policy is set to false to allow public read-only bucket policy
resource "aws_s3_bucket_public_access_block" "misconfigured_pab" {
  bucket = aws_s3_bucket.misconfigured_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SECURITY FIX: Changed from public-read-write to private ACL
resource "aws_s3_bucket_acl" "misconfigured_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
  bucket     = aws_s3_bucket.misconfigured_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.misconfigured_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# MISCONFIGURATION 3: No server-side encryption
# (Default encryption is intentionally not configured)

# MISCONFIGURATION 4: No versioning enabled
resource "aws_s3_bucket_versioning" "misconfigured_versioning" {
  bucket = aws_s3_bucket.misconfigured_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# MISCONFIGURATION 5: No access logging
# (Logging is intentionally not configured)

# SECURITY FIX: Removed public write permissions (PutObject, DeleteObject)
# Only allowing public read access if needed for legitimate use cases
resource "aws_s3_bucket_policy" "misconfigured_policy" {
  bucket = aws_s3_bucket.misconfigured_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadOnly"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.misconfigured_bucket.arn,
          "${aws_s3_bucket.misconfigured_bucket.arn}/*",
        ]
      },
    ]
  })
}

# Output the bucket name and URL
output "bucket_name" {
  value = aws_s3_bucket.misconfigured_bucket.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.misconfigured_bucket.bucket_domain_name
}

output "security_warnings" {
  value = "SECURITY FIX APPLIED: Public write access blocked. Bucket still has no encryption and no versioning."
}
