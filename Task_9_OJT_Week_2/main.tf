module "google_projects" {
  for_each        = var.projects
  source          = "./Modules/project"
  project_name    = each.value.project_name
  project_id      = each.value.project_id
  organization_id = each.value.organization_id
  billing_account = each.value.billing_account
  deletion_policy = each.value.deletion_policy
  labels          = each.value.labels
  apis            = each.value.apis
}
