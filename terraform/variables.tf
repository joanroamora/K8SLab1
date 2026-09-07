variable "project_id" {
  description = "The Google Cloud Platform (GCP) project ID"
  type        = string
  default     = "bitcitychamp-project"
}

variable "region" {
  description = "The standard GCP region where all resources will be provisioned"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Name of the Google Kubernetes Engine (GKE) cluster"
  type        = string
  default     = "gke-autopilot-lab"
}

variable "network_name" {
  description = "Name of the dedicated Virtual Private Cloud (VPC)"
  type        = string
  default     = "gke-vpc"
}

variable "subnet_name" {
  description = "Name of the primary subnetwork within the VPC"
  type        = string
  default     = "gke-subnet"
}
