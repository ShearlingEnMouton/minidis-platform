terraform {
  required_version = ">= 1.17"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.11"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
  }
  backend "gcs" {
    bucket = "project-57852789-d2db-4aec-a8b-tfstate"
    prefix = "argocd"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "helm" {
  kubernetes = {
    host                   = "https://${data.google_container_cluster.minidis.endpoint}"
    token                  = data.google_client_config.minidis.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.minidis.master_auth[0].cluster_ca_certificate)
  }
}
