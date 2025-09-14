data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source               = "../../Terraform/Modules/vpc"
  name                 = var.vpc_name
  cidr-block           = var.vpc_cidr
  enable_dns_hostnames = true
  additional_tags      = {}
}

module "pb_subnets" {
  source            = "../../Terraform/Modules/subnet"
  count             = length(var.public_subnet_names)
  name-and-cidr     = [var.public_subnet_names[count.index], var.public_subnet_cidrs[count.index]]
  availability-zone = data.aws_availability_zones.available.names[count.index]
  vpc-id            = module.vpc.id

  additional_tags = {
    "Type" = "public"
  }
}

module "igw" {
  source = "../../Terraform/Modules/internet_gateway"
  name   = var.igw_name
  vpc-id = module.vpc.id
}

module "pb-rtb" {
  source = "../../Terraform/Modules/public_route_table"
  name   = var.pb_rtb_name
  vpc-id = module.vpc.id
  igw-id = module.igw.id
}

module "public-associations" {
  source     = "../../Terraform/Modules/route_table_association"
  subnet-ids = [for m in module.pb_subnets : m.id]
  rtb-id     = module.pb-rtb.id
}
