resource "aws_route_table" "pv-rtb" {
  vpc_id = var.vpc-id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.ngw-id
  }

  tags = {
    Name = var.name
  }
}
