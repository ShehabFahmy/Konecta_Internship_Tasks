variable "project_name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "organization_id" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "apis" {
  type = list(string)
}

variable "deletion_policy" {
  type = string
}

variable "labels" {
  type = map(string)
}