variable "project_id" {
  type        = string
  description = "Google Cloud project that holds the GKE cluster"
}

variable "region" {
  type        = string
  description = "Region of the GKE cluster"
  default     = "europe-west9"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster created by terraform/gke, where Argo CD is installed"
  default     = "minidis"
}
