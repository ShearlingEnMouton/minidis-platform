variable "project_id" {
  type        = string
  description = "GCP project that holds the Terraform state bucket"
}

variable "region" {
  type        = string
  description = "Region of the state bucket"
  default     = "europe-west9"
}
