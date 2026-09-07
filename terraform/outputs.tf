output "project_id" {
  description = "ID del proyecto de GCP"
  value       = var.project_id
}

output "region" {
  description = "Región de despliegue de GCP"
  value       = var.region
}

output "cluster_name" {
  description = "Nombre del clúster GKE Autopilot"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Endpoint público del plano de control de Kubernetes"
  value       = google_container_cluster.primary.endpoint
}

output "network_name" {
  description = "Nombre de la red VPC creada"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Nombre de la subred creada"
  value       = google_compute_subnetwork.subnet.name
}

output "kubectl_connection_command" {
  description = "Comando gcloud listo para ejecutar y configurar kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}
