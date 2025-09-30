resource "google_project" "new_project" {
  name            = var.project_name
  project_id      = var.project_id       # must be globally unique
  org_id          = var.organization_id  # find with: gcloud organizations list
  billing_account = var.billing_account  # find with: gcloud beta billing accounts list
  deletion_policy = var.deletion_policy

  labels = var.labels
}

resource "google_project_service" "enabled_apis" {
  for_each = toset(var.apis)
  project = google_project.new_project.project_id
  service = each.key
}
