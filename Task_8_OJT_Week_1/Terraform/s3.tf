resource "aws_s3_bucket" "history" {
  bucket = var.bucket_name
  force_destroy = true
}
