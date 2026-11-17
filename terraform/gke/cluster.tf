resource "google_container_cluster" "default" {
  name = var.cluster_name

  location         = var.region
  enable_autopilot = true

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.subnet_region.id

  ip_allocation_policy {
    services_secondary_range_name = google_compute_subnetwork.subnet_region.secondary_ip_range[1].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.subnet_region.secondary_ip_range[0].range_name
  }

  deletion_protection = false
}