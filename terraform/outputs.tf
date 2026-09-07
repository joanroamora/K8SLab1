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

output "grafana_connection_command" {
  description = "Command to forward Grafana UI to localhost:3000"
  value       = "kubectl port-forward -n monitoring svc/grafana 3000:80"
}

output "prometheus_connection_command" {
  description = "Command to forward Prometheus UI to localhost:9090"
  value       = "kubectl port-forward -n monitoring svc/prometheus 9090:9090"
}

output "headlamp_connection_command" {
  description = "Command to forward Headlamp UI to localhost:8080"
  value       = "kubectl port-forward -n headlamp svc/headlamp 8080:80"
}
