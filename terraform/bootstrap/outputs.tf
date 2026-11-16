output "state_bucket" {
  value       = google_storage_bucket.tfstate.name
  description = "Name of the Cloud Storage bucket that stores the Terraform state of the other configurations"
}
