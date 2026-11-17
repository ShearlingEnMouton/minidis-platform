terraform {
  required_version = ">= 1.17"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.11"
    }
  }
  backend "gcs" {
    bucket = "project-57852789-d2db-4aec-a8b-tfstate"
    prefix = "gke"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
