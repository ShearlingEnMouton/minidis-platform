output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.default.name
}

output "cluster_location" {
  description = "Region of the GKE cluster"
  value       = google_container_cluster.default.location
}

output "get_credentials_command" {
  description = "Command that adds the cluster to the local kubeconfig"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.default.name} --region ${google_container_cluster.default.location} --project ${var.project_id}"
}
