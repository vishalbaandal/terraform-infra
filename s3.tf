resource "aws_s3_bucket" "project_bucket" {
  count         = var.enable_s3_bucket ? 1 : 0
  bucket        = "tf-assignment-project-bucket-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = merge(var.tags, { Name = "project-bucket" })
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.enable_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.project_bucket[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  count  = var.enable_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.project_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
