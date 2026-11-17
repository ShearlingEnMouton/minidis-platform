data "google_container_cluster" "minidis" {
  name     = var.cluster_name
  location = var.region
}

data "google_client_config" "minidis" {}
