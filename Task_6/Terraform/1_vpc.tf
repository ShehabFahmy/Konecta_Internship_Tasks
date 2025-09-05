data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source               = "./Modules/vpc"
  name                 = var.vpc_name
  cidr-block           = var.vpc_cidr
  enable_dns_hostnames = true
  additional_tags      = {}
}

module "pb_subnets" {
  source            = "./Modules/subnet"
  count             = length(var.public_subnet_names)
  name-and-cidr     = [var.public_subnet_names[count.index], var.public_subnet_cidrs[count.index]]
  availability-zone = data.aws_availability_zones.available.names[count.index]
  vpc-id            = module.vpc.id

  additional_tags = {
    "Type" = "public"
  }
}

module "pv_subnets" {
  source            = "./Modules/subnet"
  count             = length(var.private_subnet_names)
  name-and-cidr     = [var.private_subnet_names[count.index], var.private_subnet_cidrs[count.index]]
  availability-zone = data.aws_availability_zones.available.names[count.index]
  vpc-id            = module.vpc.id

  additional_tags = {
    "Type" = "private"
  }
}

module "igw" {
  source = "./Modules/internet_gateway"
  name   = var.igw_name
  vpc-id = module.vpc.id
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"
  tags = {
    Name = var.ngw_eip_name
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = module.pb_subnets[0].id
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = var.ngw_name
  }
}

module "pb-rtb" {
  source = "./Modules/public_route_table"
  name   = var.pb_rtb_name
  vpc-id = module.vpc.id
  igw-id = module.igw.id
}

module "pv-rtb" {
  source = "./Modules/private_route_table"
  name   = var.pv_rtb_name
  vpc-id = module.vpc.id
  ngw-id = aws_nat_gateway.nat_gw.id
}

module "public-associations" {
  source     = "./Modules/route_table_association"
  subnet-ids = [for m in module.pb_subnets : m.id]
  rtb-id     = module.pb-rtb.id
}

module "private-associations" {
  source     = "./Modules/route_table_association"
  subnet-ids = [for m in module.pv_subnets : m.id]
  rtb-id     = module.pv-rtb.id
}
