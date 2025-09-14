data "http" "my-public-ip" {
  url = "http://checkip.amazonaws.com"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "terraform_remote_state" "infra-project-state" {
  backend = "s3"
  config = {
    bucket = "konecta-task7-statefiles-bucket"
    key    = "infra-project/terraform.tfstate"
    region = "us-east-1"
  }
}

module "backend-secgrp" {
  source      = "./Modules/security_group"
  secgrp-name = var.backend_secgrp_name
  vpc-id      = data.terraform_remote_state.infra-project-state.outputs.vpc-id
  # Allow SSH for your local machine's public IP and Jenkins security group for Ansible's SSH connection
  ingress-data = [{ from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["${trimspace(data.http.my-public-ip.response_body)}/32"], security_groups = [] },
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = [], security_groups = [data.terraform_remote_state.infra-project-state.outputs.jenkins-secgrp-id] },
  { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], security_groups = [] }]
  egress-data = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
}

resource "aws_instance" "backend-ec2" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = data.terraform_remote_state.infra-project-state.outputs.key-pair-name
  associate_public_ip_address = true
  subnet_id                   = data.terraform_remote_state.infra-project-state.outputs.backend-subnet-id
  security_groups             = [module.backend-secgrp.id]

  tags = var.backend_instance_tags
}
