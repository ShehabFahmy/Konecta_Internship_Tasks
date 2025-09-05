resource "aws_vpc" "vpc" {
  cidr_block = var.cidr-block
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge({Name = var.name}, var.additional_tags)
}
