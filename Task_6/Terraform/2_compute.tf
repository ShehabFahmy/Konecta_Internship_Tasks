data "http" "my-public-ip" {
  url = "http://checkip.amazonaws.com"
}

module "key-pair" {
  source   = "./Modules/key_pair"
  key-name = var.key_pair_name
}

module "nginx-secgrp" {
  source      = "./Modules/security_group"
  secgrp-name = var.nginx_secgrp_name
  vpc-id      = module.vpc.id
  # Allow SSH for your local machine's public IP
  ingress-data = [{ from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["${trimspace(data.http.my-public-ip.response_body)}/32"], security_groups = [] },
  { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], security_groups = [] }]
  egress-data = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
}

module "pv-secgrp" {
  source      = "./Modules/security_group"
  secgrp-name = var.pv_secgrp_name
  vpc-id      = module.vpc.id
  # Allow SSH for the public instance only to serve as a Bastion host
  ingress-data = [{ from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = [], security_groups = [module.nginx-secgrp.id] },
  { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [], security_groups = [module.nginx-secgrp.id] }]
  egress-data = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }]
}

module "nginx-ec2" {
  source                 = "./Modules/aws_linux_ec2_remote_exec"
  aws-linux-instance-ami = var.instance_ami
  instance-type          = var.instance_type
  key-name               = var.key_pair_name
  private-key-path       = module.key-pair.private-key-path
  is-public              = true
  subnet-id              = module.pb_subnets[0].id
  secgrp-id              = module.nginx-secgrp.id
  remote-exec-inline     = <<-EOF
    #!/bin/bash
    ${var.nginx-installation}
    echo "Hello From Proxy1 Instance!" | sudo tee /usr/share/nginx/html/index.html
    sudo tee /etc/nginx/conf.d/proxy.conf > /dev/null <<EOT
server {
    listen 80;

    location / {
        proxy_pass http://${aws_instance.pv-ec2.private_ip};
    }
}
EOT
    sudo systemctl restart nginx
    EOF
  tags = {
    Name = var.nginx_instance_name
  }
}

resource "aws_instance" "pv-ec2" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  associate_public_ip_address = false
  subnet_id                   = module.pv_subnets[0].id
  security_groups             = [module.pv-secgrp.id]
  user_data                   = <<-EOF
    #!/bin/bash
    ${var.nginx-installation}
    echo "Hello From Private Instance!" | sudo tee /usr/share/nginx/html/index.html
    sudo systemctl restart nginx
    EOF
  tags = {
    "Name" = var.pv_instance_name
  }
}