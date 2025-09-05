aws_region = "us-east-1"

vpc_name            = "konecta-task6-vpc"
vpc_cidr            = "10.0.0.0/16"
public_subnet_names = ["konecta-task6-pb-subnet"]
public_subnet_cidrs = ["10.0.1.0/24"]
private_subnet_names = ["konecta-task6-pv-subnet"]
private_subnet_cidrs = ["10.0.2.0/24"]
igw_name            = "konecta-task6-igw"
ngw_eip_name        = "konecta-task6-ngw-eip"
ngw_name            = "konecta-task6-ngw"
pb_rtb_name         = "konecta-task6-pb-rtb"
pv_rtb_name         = "konecta-task6-pv-rtb"

key_pair_name       = "konecta-task6-keypair"
nginx_secgrp_name   = "konecta-task6-nginx-secgrp"
nginx_instance_name = "konecta-task6-nginx-instance"
pv_secgrp_name      = "konecta-task6-pv-secgrp"
pv_instance_name    = "konecta-task6-pv-instance"
instance_ami        = "ami-00ca32bbc84273381"
instance_type       = "t3.micro"