# ==============================================================================
# Habilitación de APIs necesarias de GCP
# ==============================================================================
resource "google_project_service" "container" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# ==============================================================================
# Infraestructura de Red (VPC y Subred dedicada)
# ==============================================================================
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  description             = "VPC dedicada y aislada para el clúster de GKE"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  ip_cidr_range            = "10.10.0.0/20"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true

  # Rango secundario para las IPs de los Pods (VPC-Native)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  # Rango secundario para las IPs de los Services (ClusterIPs)
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

# ==============================================================================
# Cloud Router y Cloud NAT para salida segura a Internet (Docker Hub, APIs, etc.)
# ==============================================================================
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ==============================================================================
# Clúster de Google Kubernetes Engine (GKE) - Modo Autopilot
# ==============================================================================
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # Habilita el modo Autopilot: aprovisionamiento, escalado y seguridad totalmente gestionados
  enable_autopilot = true

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # CRÍTICO: Permite que 'terraform destroy' elimine el clúster sin bloqueos de protección
  deletion_protection = false

  # Endpoint público para administración vía kubectl y nodos privados para máxima seguridad
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  release_channel {
    channel = "REGULAR"
  }

  depends_on = [
    google_project_service.container,
    google_compute_router_nat.nat
  ]
}
