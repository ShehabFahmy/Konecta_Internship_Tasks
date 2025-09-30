variable "projects" {
  type = map(object({
    project_name    = string
    project_id      = string
    organization_id = string
    billing_account = string
    deletion_policy = string
    labels          = map(string)
    apis            = list(string)
  }))
}