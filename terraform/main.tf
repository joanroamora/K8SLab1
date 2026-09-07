# ==============================================================================
# GCP Required APIs Enablement
# ==============================================================================
resource "google_project_service" "container" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# ==============================================================================
# Network Infrastructure (Dedicated VPC and Subnet)
# ==============================================================================
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  description             = "Dedicated and isolated VPC for the GKE cluster"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  ip_cidr_range            = "10.10.0.0/20"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true

  # Secondary IP range for Pods (VPC-Native)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  # Secondary IP range for Services (ClusterIPs)
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

# ==============================================================================
# Cloud Router & Cloud NAT for Secure Egress (Docker Hub, APIs, etc.)
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
# Google Kubernetes Engine (GKE) Cluster - Autopilot Mode
# ==============================================================================
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # Enable Autopilot mode: fully managed provisioning, scaling, and security
  enable_autopilot = true

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # CRITICAL: Allows 'terraform destroy' to cleanly remove the cluster without deletion protection locks
  deletion_protection = false

  # Public endpoint for kubectl administration and private nodes for maximum security
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  release_channel {
    channel = "REGULAR"
  }

  # Observability and Telemetry configuration
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER", "STORAGE", "POD", "DEPLOYMENT"]
    managed_prometheus {
      enabled = true
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  depends_on = [
    google_project_service.container,
    google_compute_router_nat.nat
  ]
}
