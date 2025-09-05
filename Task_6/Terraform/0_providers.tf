provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket       = "konecta-task6-statefile-bucket"
    key          = "statefile/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true #S3 native locking
  }
}