variable "aws_region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "public_subnet_names" {
  type = list(string)
}

variable "private_subnet_names" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "igw_name" {
  type = string
}

variable "ngw_eip_name" {
  type = string
}

variable "ngw_name" {
  type = string
}

variable "pb_rtb_name" {
  type = string
}

variable "pv_rtb_name" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "nginx_secgrp_name" {
  type = string
}

variable "nginx_instance_name" {
  type = string
}

variable "pv_secgrp_name" {
  type = string
}

variable "pv_instance_name" {
  type = string
}

variable "instance_ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "nginx-installation" {
  default = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx
              sudo service nginx start
              EOF
}