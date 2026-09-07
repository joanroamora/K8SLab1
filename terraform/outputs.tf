output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP deployment region"
  value       = var.region
}

output "cluster_name" {
  description = "Name of the GKE Autopilot cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Public endpoint for the Kubernetes control plane"
  value       = google_container_cluster.primary.endpoint
}

output "network_name" {
  description = "Name of the provisioned VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Name of the provisioned subnetwork"
  value       = google_compute_subnetwork.subnet.name
}

output "kubectl_connection_command" {
  description = "Ready-to-use gcloud command to configure kubectl credentials"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}
