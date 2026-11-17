variable "project_id" {
  type        = string
  description = "Google Cloud project that holds the network and the GKE cluster"
}

variable "region" {
  type        = string
  description = "Region of the subnet and the regional GKE Autopilot cluster"
  default     = "europe-west9"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
  default     = "minidis"
}

# https://docs.cloud.google.com/kubernetes-engine/docs/concepts/alias-ips
variable "subnet_node" {
  type        = string
  default     = "10.10.0.0/20"
  description = "Primary IP range of the subnet, used for node IP addresses"
}

variable "subnet_pod" {
  type        = string
  default     = "10.20.0.0/16"
  description = "Secondary IP range of the subnet, used for Pod IP addresses"
}

variable "subnet_service" {
  type        = string
  default     = "10.30.0.0/20"
  description = "Secondary IP range of the subnet, used for Service ClusterIP addresses"
}
