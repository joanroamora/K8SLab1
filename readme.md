# 🚀 Kubernetes Lab on Google Cloud Platform (GCP)

This repository provides a complete two-layer architecture to deploy, manage, and observe cloud-native applications on **Google Kubernetes Engine (GKE Autopilot)**.

---

## 🏗️ Project Structure

```text
.
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
  - **Grafana:** Pre-configured with automated Prometheus datasource and a comprehensive, production-grade **Online Boutique Microservices Dashboard** measuring per-microservice CPU, memory, network RX/TX, and replica health.
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