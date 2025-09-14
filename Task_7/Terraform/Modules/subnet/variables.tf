variable "vpc-id" {
  type = string
}

variable "name-and-cidr" {
  type = tuple([string, string])
  description = "tuple(name, cidr-block)"
}

variable "availability-zone" {
  type = string
}

variable "additional_tags" {
  type = map(string)
}