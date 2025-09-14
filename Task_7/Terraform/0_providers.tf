provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket       = "konecta-task7-statefiles-bucket"
    key          = "infra-app/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true #S3 native locking
  }
}