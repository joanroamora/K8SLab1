# 🚀 Laboratorio Kubernetes en Google Cloud Platform (GCP)

Este repositorio contiene la arquitectura completa en dos capas para desplegar, gestionar y observar aplicaciones nativas de la nube en **Google Kubernetes Engine (GKE Autopilot)**.

---

## 🏗️ Estructura del Proyecto

```text
.
├── terraform/                # [Capa 1] Infraestructura Base como Código (IaC)
│   ├── main.tf               # VPC, Subnets, Cloud Router, Cloud NAT y Clúster GKE Autopilot
│   ├── variables.tf          # Definición de variables parametrizables
│   ├── outputs.tf            # Endpoints, comando kubectl y datos de red
│   └── provider.tf           # Configuración del proveedor HashiCorp Google Cloud
│
└── kubernetes/               # [Capa 2] Cargas de Trabajo y Control Plane Didáctico
    └── manifests/
        ├── 00-namespaces/    # Espacios de nombres 'boutique' y 'headlamp'
        ├── 01-boutique/      # Suite de microservicios de Google Online Boutique
        ├── 02-dashboard/     # Headlamp UI Dashboard + RBAC
        ├── kustomization.yaml# Despliegue unificado con Kustomize
        └── README.md         # Guía detallada paso a paso y laboratorios prácticos
```

---

## 📚 Capas del Laboratorio

### 1. Capa 1: Infraestructura Base (Terraform)
- **VPC Nativa y Aislada:** `gke-vpc` con subred `10.10.0.0/20` y rangos secundarios dedicados para Pods (`10.20.0.0/16`) y Services (`10.30.0.0/20`).
- **Cloud Router & NAT:** Salida a Internet transparente y segura para nodos privados.
- **GKE Autopilot:** Clúster completamente gestionado en `us-central1` con nodos privados y endpoint público para administración remota.
- Consulta [terraform/](file:///home/joanr/agentic-platforms/GCP/K8SLab1/terraform) para detalles de aprovisionamiento.

### 2. Capa 2: Aplicación y Control Plane (Kubernetes Manifests)
- **Online Boutique:** 12 microservicios políglotas (Go, C#, Python, Node.js, Java, Redis) con balanceador público de GCP (`LoadBalancer`) asignado al frontend.
- **Headlamp Dashboard:** Panel visual para monitorizar pods, deployments, servicios, logs y consumo en caliente vía `kubectl port-forward`.
- Consulta la guía completa de despliegue y laboratorios en [kubernetes/manifests/README.md](file:///home/joanr/agentic-platforms/GCP/K8SLab1/kubernetes/manifests/README.md).

---

## ⚡ Inicio Rápido (Despliegue de Capa 2)

```bash
# 1. Enlazar credenciales con tu clúster
gcloud container clusters get-credentials gke-autopilot-lab --region us-central1 --project bitcitychamp-project

# 2. Desplegar toda la arquitectura de la Capa 2
kubectl apply -k kubernetes/manifests

# 3. Consultar la IP externa de la tienda
kubectl get svc frontend-external -n boutique -w

# 4. Acceder al dashboard de control
kubectl port-forward -n headlamp svc/headlamp 8080:80
```