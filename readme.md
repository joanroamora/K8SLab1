# 🚀 Kubernetes Lab on Google Cloud Platform (GCP)

This repository provides a complete two-layer architecture to deploy, manage, and observe cloud-native applications on **Google Kubernetes Engine (GKE Autopilot)**.

---

## 🏗️ Project Structure

```text
.
├── .github/
│   └── workflows/
│       ├── terraform.yml     # [CI/CD] Terraform fmt, init, validate, PR plan & CD apply on main
│       └── kubernetes.yml    # [CI/CD] yamllint, kustomize build & CD deploy to GKE on main
├── .yamllint.yml             # Linting standards for Kubernetes manifests
├── terraform/                # [Layer 1] Base Infrastructure as Code (IaC)
│   ├── main.tf               # VPC, Subnets, Cloud Router, Cloud NAT, and GKE Autopilot Cluster
│   ├── monitoring.tf         # Automated deployment orchestration for K8s workloads & monitoring
│   ├── variables.tf          # Configurable variable definitions
│   ├── outputs.tf            # Endpoints, connection commands, and network metadata
│   └── provider.tf           # HashiCorp Google Cloud provider configuration
│
└── kubernetes/               # [Layer 2] Workloads, Control Plane & Observability
    └── manifests/
        ├── 00-namespaces/    # 'boutique', 'headlamp', and 'monitoring' namespaces
        ├── 01-boutique/      # Google Online Boutique microservices suite
        ├── 02-dashboard/     # Headlamp UI Dashboard + RBAC
        ├── 03-monitoring/    # Prometheus Server, kube-state-metrics & Grafana with Dashboards
        ├── kustomization.yaml# Unified atomic deployment with Kustomize
        └── README.md         # In-depth architectural guide and hands-on lab exercises
```

---

## 📚 Architecture Layers

### 1. Layer 1: Base Infrastructure (Terraform)
- **Native & Isolated VPC:** `gke-vpc` with subnet `10.10.0.0/20` and dedicated secondary ranges for Pods (`10.20.0.0/16`) and Services (`10.30.0.0/20`).
- **Cloud Router & Cloud NAT:** Secure, transparent egress for private nodes to pull container images and access external APIs.
- **GKE Autopilot:** Fully managed Kubernetes cluster in `us-central1` with private nodes, public endpoint for administrative access, and Google Cloud Managed Prometheus enabled.
- **Automated Workload Deployment:** Optional orchestration via `terraform_data` in [`terraform/monitoring.tf`](file:///home/joanr/agentic-platforms/GCP/K8SLab1/terraform/monitoring.tf) that applies all Kubernetes manifests automatically on `terraform apply` and cleans them up before `terraform destroy`.
- See [terraform/](file:///home/joanr/agentic-platforms/GCP/K8SLab1/terraform) for provisioning details.

### 2. Layer 2: Application, Control Plane & Observability (Kubernetes Manifests)
- **Online Boutique:** 12 polyglot microservices (Go, C#, Python, Node.js, Java, Redis) with a GCP external `LoadBalancer` assigned to the frontend.
- **Headlamp Dashboard:** Modern, reactive web UI for inspecting pods, deployments, services, logs, and real-time resource utilization via `kubectl port-forward`.
- **Prometheus & Grafana Monitoring Stack:** Complete observability suite in namespace `monitoring`:
  - **Prometheus:** High-performance telemetry server scraping cAdvisor container metrics, kube-state-metrics, and pod annotations.
  - **kube-state-metrics:** Exposes cluster-level object metrics, pod lifecycle states, and container restart counters.
  - **Grafana:** Pre-configured with automated Prometheus datasource and a comprehensive, production-grade **Online Boutique SRE Telemetry & Performance Dashboard** tracking **Google SRE Golden Signals**, **RED Method** (Request Rate RPS, HTTP Error Rate by status code, Latency Mean vs p50/p95/p99), **USE Method** (Memory & CPU CFS Throttling Saturation), and **SLI/SLO Availability (99.9%)**.
- See the complete deployment guide and lab exercises in [kubernetes/manifests/README.md](file:///home/joanr/agentic-platforms/GCP/K8SLab1/kubernetes/manifests/README.md).

---

## ⚡ Quick Start (Layer 2 Deployment)

```bash
# 1. Connect kubectl credentials to your cluster
gcloud container clusters get-credentials gke-autopilot-lab --region us-central1 --project bitcitychamp-project

# 2. Deploy the complete Layer 2 architecture (Boutique + Headlamp + Monitoring)
kubectl apply -k kubernetes/manifests

# 3. Retrieve the external IP for the storefront
kubectl get svc frontend-external -n boutique -w

# 4. Access the Headlamp control plane dashboard
kubectl port-forward -n headlamp svc/headlamp 8080:80

# 5. Access the Grafana observability dashboard (Anonymous Admin enabled)
kubectl port-forward -n monitoring svc/grafana 3000:80
# Open http://localhost:3000 in your browser

# 6. (Optional) Access the Prometheus Query UI
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Open http://localhost:9090 in your browser
```

---

## 🔄 9. Enterprise CI/CD Automation (GitHub Actions)

This repository includes two decoupled, production-grade GitHub Actions workflows following industry standards:

### 1. Infrastructure Pipeline (`.github/workflows/terraform.yml`)
* **Continuous Integration (Pull Requests to `main`):**
  - Runs `terraform fmt -check` to enforce code formatting.
  - Runs `terraform init` and `terraform validate`.
  - Generates a speculative `terraform plan` and automatically posts a formatted, collapsible summary as a comment directly on the Pull Request.
* **Continuous Deployment (Push / Merge to `main`):**
  - Automatically runs `terraform apply -auto-approve` to provision or update GCP resources.

### 2. Workloads & Observability Pipeline (`.github/workflows/kubernetes.yml`)
* **Continuous Integration (Pull Requests to `main`):**
  - Runs `yamllint` using `.yamllint.yml` standards across all Kubernetes manifests.
  - Validates full compilation and schemas with `kustomize build kubernetes/manifests/`.
* **Continuous Deployment (Push / Merge to `main`):**
  - Authenticates to Google Cloud and configures GKE credentials for cluster `gke-autopilot-lab`.
  - Deploys workloads atomically using `kubectl apply -k kubernetes/manifests/`.
  - Verifies rollout health across `frontend`, `cartservice`, `grafana`, and `prometheus`.

### 🔐 Required GitHub Repository Secrets

To enable these workflows in your GitHub repository (**Settings > Secrets and variables > Actions**), configure:

| Secret Name | Description | Example / Value |
| :--- | :--- | :--- |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID | `bitcitychamp-project` |
| `GCP_SA_KEY` | GCP Service Account Key (JSON) with GKE and Compute permissions | `{"type": "service_account", ...}` |