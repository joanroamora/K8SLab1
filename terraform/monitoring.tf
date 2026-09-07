# ==============================================================================
# Automated Kubernetes & Observability Manifest Deployment (Layer 2 via IaC)
# ==============================================================================
resource "terraform_data" "k8s_workloads" {
  count = var.enable_monitoring_automation ? 1 : 0

  triggers_replace = [
    google_container_cluster.primary.id,
    filesha256("${path.module}/../kubernetes/manifests/kustomization.yaml"),
    filesha256("${path.module}/../kubernetes/manifests/00-namespaces/namespace.yaml"),
    filesha256("${path.module}/../kubernetes/manifests/03-monitoring/01-prometheus.yaml"),
    filesha256("${path.module}/../kubernetes/manifests/03-monitoring/02-kube-state-metrics.yaml"),
    filesha256("${path.module}/../kubernetes/manifests/03-monitoring/03-grafana.yaml")
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "==> Configuring kubectl credentials for ${google_container_cluster.primary.name}..."
      gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}
      echo "==> Deploying Unified Kubernetes Manifests (Boutique, Headlamp, and Observability)..."
      kubectl apply -k ${path.module}/../kubernetes/manifests
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "==> Cleaning up Kubernetes workloads before cluster teardown..."
      kubectl delete -k ${path.module}/../kubernetes/manifests --ignore-not-found=true || true
    EOT
  }

  depends_on = [
    google_container_cluster.primary
  ]
}
