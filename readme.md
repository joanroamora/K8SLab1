# 🚀 Kubernetes Lab on Google Cloud Platform (GCP)

This repository provides a complete two-layer architecture to deploy, manage, and observe cloud-native applications on **Google Kubernetes Engine (GKE Autopilot)**.

---

## 🏗️ Project Structure

```text
.
├── terraform/                # [Layer 1] Base Infrastructure as Code (IaC)
│   ├── main.tf               # VPC, Subnets, Cloud Router, Cloud NAT, and GKE Autopilot Cluster
│   ├── variables.tf          # Configurable variable definitions
│   ├── outputs.tf            # Endpoints, kubectl connection command, and network metadata
│   └── provider.tf           # HashiCorp Google Cloud provider configuration
│
└── kubernetes/               # [Layer 2] Workloads & Didactic Control Plane
    └── manifests/
        ├── 00-namespaces/    # 'boutique' and 'headlamp' namespaces
        ├── 01-boutique/      # Google Online Boutique microservices suite
        ├── 02-dashboard/     # Headlamp UI Dashboard + RBAC
        ├── kustomization.yaml# Unified atomic deployment with Kustomize
        └── README.md         # In-depth architectural guide and hands-on lab exercises
```

---

## 📚 Architecture Layers

### 1. Layer 1: Base Infrastructure (Terraform)
- **Native & Isolated VPC:** `gke-vpc` with subnet `10.10.0.0/20` and dedicated secondary ranges for Pods (`10.20.0.0/16`) and Services (`10.30.0.0/20`).
- **Cloud Router & Cloud NAT:** Secure, transparent egress for private nodes to pull container images and access external APIs.
- **GKE Autopilot:** Fully managed Kubernetes cluster in `us-central1` with private nodes and a public endpoint for administrative access.
- See [terraform/](file:///home/joanr/agentic-platforms/GCP/K8SLab1/terraform) for provisioning details.

### 2. Layer 2: Application & Control Plane (Kubernetes Manifests)
- **Online Boutique:** 12 polyglot microservices (Go, C#, Python, Node.js, Java, Redis) with a GCP external `LoadBalancer` assigned to the frontend.
- **Headlamp Dashboard:** Modern, reactive web UI for inspecting pods, deployments, services, logs, and real-time resource utilization via `kubectl port-forward`.
- See the complete deployment guide and lab exercises in [kubernetes/manifests/README.md](file:///home/joanr/agentic-platforms/GCP/K8SLab1/kubernetes/manifests/README.md).

---

## ⚡ Quick Start (Layer 2 Deployment)

```bash
# 1. Connect kubectl credentials to your cluster
gcloud container clusters get-credentials gke-autopilot-lab --region us-central1 --project bitcitychamp-project

# 2. Deploy the complete Layer 2 architecture
kubectl apply -k kubernetes/manifests

# 3. Retrieve the external IP for the storefront
kubectl get svc frontend-external -n boutique -w

# 4. Access the Headlamp control plane dashboard
kubectl port-forward -n headlamp svc/headlamp 8080:80
```