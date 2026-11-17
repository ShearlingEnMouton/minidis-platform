locals {
  gcp_service_list = [
    # gcloud services list --filter="name:container"
    "container.googleapis.com",
    "compute.googleapis.com"
  ]
}

resource "google_project_service" "enabled_apis" {
  for_each = toset(local.gcp_service_list)
  service  = each.key

  disable_on_destroy = false
}
