aws_region = "us-east-1"

vpc_name            = "konecta-task7-vpc"
vpc_cidr            = "10.0.0.0/16"
public_subnet_names = ["konecta-task7-pb-subnet1", "konecta-task7-pb-subnet2"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
igw_name            = "konecta-task7-igw"
pb_rtb_name         = "konecta-task7-pb-rtb"

key_pair_name         = "konecta-task7-keypair"
jenkins_secgrp_name   = "konecta-task7-jenkins-secgrp"
jenkins_instance_name = "konecta-task7-jenkins-server"
instance_ami          = "ami-0360c520857e3138f"  # Ubuntu
instance_type         = "t3.small"