variable "name" {
  type = string
}

variable "cidr-block" {
  type = string
}

variable "additional_tags" {
  type = map(string)
}

variable "enable_dns_hostnames" {
  type = bool
  default = false
}