# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork

resource "google_compute_network" "vpc_network" {
  name                    = var.cluster_name
  auto_create_subnetworks = false

  depends_on = [google_project_service.enabled_apis]
}

resource "google_compute_subnetwork" "subnet_region" {
  name          = "${var.region}-subnetwork"
  ip_cidr_range = var.subnet_node
  region        = var.region
  network       = google_compute_network.vpc_network.id

  secondary_ip_range {
    range_name    = "${var.cluster_name}-secondary-range-pod"
    ip_cidr_range = var.subnet_pod
  }

  secondary_ip_range {
    range_name    = "${var.cluster_name}-secondary-range-service"
    ip_cidr_range = var.subnet_service
  }

  #   log_config {
  #     aggregation_interval = "INTERVAL_10_MIN"
  #     flow_sampling        = 0.5
  #     metadata             = "INCLUDE_ALL_METADATA"
  #   }
}
