variable "project_id" {
  description = "El ID del proyecto de Google Cloud Platform (GCP)"
  type        = string
  default     = "bitcitychamp-project"
}

variable "region" {
  description = "La región estándar de GCP donde se aprovisionarán todos los recursos"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Nombre del clúster de Google Kubernetes Engine (GKE)"
  type        = string
  default     = "gke-autopilot-lab"
}

variable "network_name" {
  description = "Nombre de la Virtual Private Cloud (VPC) dedicada"
  type        = string
  default     = "gke-vpc"
}

variable "subnet_name" {
  description = "Nombre de la subred principal dentro de la VPC"
  type        = string
  default     = "gke-subnet"
}
