variable "aws_region" {
  type = string
}

variable "backend_secgrp_name" {
  type = string
}

variable "backend_instance_tags" {
  type = map(string)
}

variable "instance_ami" {
  type = string
}

variable "instance_type" {
  type = string
}
