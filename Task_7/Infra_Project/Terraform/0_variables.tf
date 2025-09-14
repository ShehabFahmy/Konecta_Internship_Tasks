variable "aws_region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_names" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "igw_name" {
  type = string
}

variable "pb_rtb_name" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "jenkins_secgrp_name" {
  type = string
}

variable "jenkins_instance_name" {
  type = string
}

variable "instance_ami" {
  type = string
}

variable "instance_type" {
  type = string
}
