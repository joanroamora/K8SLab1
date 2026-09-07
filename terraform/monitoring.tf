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
    command = "echo 'Layer 2 workloads managed via dedicated Kubernetes CD workflow'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Layer 2 workload cleanup handled prior to cluster teardown'"
  }

  depends_on = [
    google_container_cluster.primary
  ]
}
