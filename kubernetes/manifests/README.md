# 🏛️ Layer 2: Workloads & Didactic Control Plane (Cloud Native & Kubernetes)

Welcome to **Layer 2 of the Kubernetes Lab on Google Cloud Platform (GCP)**. Structured with production-grade engineering practices and an educational hands-on focus, this guide walks you through deploying, observing, interacting with, and troubleshooting workloads on a **GKE Autopilot** cluster.

---

## 📐 1. System Architecture

The deployment is split into two isolated domains via Namespaces:
1. **`boutique` (Application Layer):** The complete polyglot microservices suite from **Google Cloud Online Boutique**, designed to demonstrate synchronous gRPC/HTTP communication, Redis in-memory caching, and L4 external load balancing via Google Cloud Load Balancing.
2. **`headlamp` (Observability & Control Layer):** A modern, reactive, lightweight web dashboard developed under the **Kubernetes SIGs UI** project, configured with scoped RBAC for real-time cluster inspection.

```mermaid
graph TD
    subgraph Internet ["🌐 Internet / Users"]
        User["💻 Web Browser"]
        Instructor["👨‍🏫 Terminal / Admin"]
    end

    subgraph GCP ["☁️ Google Cloud Platform (VPC: gke-vpc)"]
        GCP_LB["⚖️ Google Cloud External Load Balancer (Public IP)"]
        
        subgraph GKE ["☸️ GKE Autopilot Cluster (us-central1)"]
            
            subgraph NS_Boutique ["Namespace: boutique"]
                FE_SVC["Service: frontend-external (LoadBalancer)"]
                FE["Pod: frontend (Go)"]
                
                CART["Pod: cartservice (C#)"]
                REDIS["Pod: redis-cart (Redis)"]
                CATALOG["Pod: productcatalogservice (Go)"]
                CURRENCY["Pod: currencyservice (Node.js)"]
                PAYMENT["Pod: paymentservice (Node.js)"]
                SHIPPING["Pod: shippingservice (Go)"]
                EMAIL["Pod: emailservice (Python)"]
                CHECKOUT["Pod: checkoutservice (Go)"]
                RECOM["Pod: recommendationservice (Python)"]
                AD["Pod: adservice (Java)"]
                LOADGEN["Pod: loadgenerator (Locust/Python)"]
            end
            
            subgraph NS_Headlamp ["Namespace: headlamp"]
                HL_SVC["Service: headlamp (ClusterIP:4466)"]
                HL["Pod: headlamp (UI Dashboard)"]
                RBAC["ServiceAccount & RBAC: headlamp-admin"]
            end
        end
    end

    User -->|HTTP :80| GCP_LB
    GCP_LB --> FE_SVC
    FE_SVC --> FE
    
    FE --> CART & CATALOG & CURRENCY & SHIPPING & CHECKOUT & RECOM & AD
    CART --> REDIS
    CHECKOUT --> PAYMENT & SHIPPING & EMAIL & CART & CATALOG & CURRENCY
    LOADGEN -.->|Synthetic Traffic| FE
    
    Instructor -->|kubectl port-forward :8080| HL_SVC
    HL_SVC --> HL
    HL -.->|Reads cluster metrics and state| RBAC
```

---

## 🗂️ 2. Manifest Directory Structure

```text
kubernetes/manifests/
├── 00-namespaces/
│   └── namespace.yaml                  # Defines 'boutique' and 'headlamp' namespaces
├── 01-boutique/
│   ├── 01-emailservice.yaml            # Email notifications (Python)
│   ├── 02-checkoutservice.yaml         # Checkout flow orchestrator (Go)
│   ├── 03-recommendationservice.yaml   # Product recommendation engine (Python)
│   ├── 04-frontend.yaml                # Web UI + External LoadBalancer service (Go)
│   ├── 05-paymentservice.yaml          # Payment and credit card processing (Node.js)
│   ├── 06-productcatalogservice.yaml   # Product search & catalog (Go)
│   ├── 07-cartservice.yaml             # Shopping cart state management (C# .NET)
│   ├── 08-currencyservice.yaml         # International currency conversions (Node.js)
│   ├── 09-shippingservice.yaml         # Shipping cost calculation and tracking (Go)
│   ├── 10-adservice.yaml               # Targeted contextual ads (Java)
│   ├── 11-redis-cart.yaml              # In-memory key-value cache for carts (Redis)
│   ├── 12-loadgenerator.yaml          # Background synthetic traffic generator (Locust)
│   └── release-complete.yaml           # Consolidated manifest for all 12 microservices
├── 02-dashboard/
│   └── 01-headlamp.yaml                # Headlamp UI, ServiceAccount, RBAC, and Secret token
├── kustomization.yaml                  # Kustomize declaration for unified atomic deployment
└── README.md                           # This technical and interactive guide
```

---

## 🚀 3. Step-by-Step Deployment Guide

### Prerequisite: Connect `kubectl` to your GKE Cluster
Ensure your local CLI is authenticated against the cluster provisioned by Terraform:

```bash
gcloud container clusters get-credentials gke-autopilot-lab \
    --region us-central1 \
    --project bitcitychamp-project
```

Verify connectivity:
```bash
kubectl cluster-info
```

---

### Option A: Atomic Deployment via Kustomize (Recommended)
Apply the complete architecture (Namespaces, Microservices, and Dashboard) with a single command:

```bash
kubectl apply -k kubernetes/manifests
```

---

### Option B: Modular Step-by-Step Deployment (Didactic)

#### Step 1: Create the Namespaces
```bash
kubectl apply -f kubernetes/manifests/00-namespaces/namespace.yaml
```
Verify creation:
```bash
kubectl get namespaces -L app.kubernetes.io/part-of
```

#### Step 2: Deploy the Microservices Storefront
You can apply the consolidated manifest:
```bash
kubectl apply -f kubernetes/manifests/01-boutique/release-complete.yaml
```
*Or deploy each service individually from `kubernetes/manifests/01-boutique/` to explain each component's role to your team.*

Monitor pod provisioning (in GKE Autopilot, the cluster dynamically provisions and scales worker nodes to accommodate workloads):
```bash
kubectl get pods -n boutique -w
```
*(Wait until all pods reach the `Running` 1/1 state).*

#### Step 3: Deploy the Visual Control Plane (Headlamp)
```bash
kubectl apply -f kubernetes/manifests/02-dashboard/01-headlamp.yaml
```
Verify the dashboard rollout:
```bash
kubectl rollout status deployment/headlamp -n headlamp
```

---

## 🌐 4. Accessing the Microservices Storefront (Online Boutique)

The `frontend-external` service is configured with `type: LoadBalancer`. Google Cloud automatically provisions an external network load balancer and assigns a public IP address.

### 1. Retrieve the Public IP
Run:
```bash
kubectl get svc frontend-external -n boutique
```

Expected output:
```text
NAME                TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
frontend-external   LoadBalancer   10.30.12.84    34.123.45.67     80:31234/TCP   2m
```

> [!NOTE]
> If `EXTERNAL-IP` displays `<pending>`, GCP is still binding the forwarding rule and health checks. Wait 30 to 60 seconds and run `kubectl get svc frontend-external -n boutique -w`.

### 2. Explore the Storefront
Open in your browser:
```text
http://<EXTERNAL-IP>
```
You can browse products, add items to your cart, switch currencies (USD, EUR, JPY), and place orders.

---

## 📊 5. Accessing the Visual Control Plane (Headlamp UI)

Following cloud-native security best practices, the dashboard is exposed via `ClusterIP` and accessed through a secure, local encrypted tunnel (`kubectl port-forward`).

### 1. Start the Local Port-Forward
Run in your terminal:
```bash
kubectl port-forward -n headlamp svc/headlamp 8080:80
```

### 2. Generate the RBAC Authentication Token
On **GKE Autopilot** (where Google Cloud OIDC token validation is enforced), the Kubernetes API Server validates OIDC signatures and cluster audience (`aud`). Generate a dynamic token using:

```bash
kubectl create token headlamp-admin -n headlamp --duration=48h
```

*(Copy the generated token string to paste into the login screen).*

### 3. Log into Headlamp
1. Navigate to: **[http://localhost:8080](http://localhost:8080)**
2. Select the **Token** authentication option.
3. Paste the token from step 2 and click **Sign In**.

---

## 🔬 6. Hands-On Observability & Diagnostics Labs

Use these practical exercises to demonstrate core Kubernetes and GKE Autopilot capabilities:

### Lab A: Self-Healing Pods
1. In Headlamp, open **Workloads > Pods** filtered by the `boutique` namespace.
2. In your terminal, delete the frontend or product catalog pod:
   ```bash
   kubectl delete pod -l app=productcatalogservice -n boutique
   ```
3. Watch Headlamp: the **ReplicaSet** instantly reconciles the observed state against the desired state, spinning up a healthy replacement pod in seconds with zero downtime.

### Lab B: Synthetic Traffic Injection & Monitoring
The `loadgenerator` microservice uses Locust to simulate concurrent user traffic browsing products, managing carts, and checking out.
1. Stream the live traffic generator logs:
   ```bash
   kubectl logs -n boutique -l app=loadgenerator -c main -f
   ```
2. In Headlamp, observe CPU and memory usage for `frontend` and `cartservice` as they handle requests.

### Lab C: Live Log Inspection & Interactive Container Terminal
1. In Headlamp, click on the `redis-cart` pod.
2. Click **Logs** in the top navigation bar to view real-time cache reads and writes.
3. Click **Terminal** to open an interactive shell inside the container and test with `redis-cli ping` (you will receive `PONG`).

---

## 🧹 7. Cleaning Up Layer 2 Resources

When testing is complete and you want to tear down the workloads without destroying the underlying Terraform infrastructure:

```bash
# Delete all resources managed via Kustomize
kubectl delete -k kubernetes/manifests

# Or delete the namespaces directly for a clean cascading teardown
kubectl delete namespace boutique headlamp
```

