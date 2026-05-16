# 🏗️ Multi-Service Platform Provisioner

## 🚀 Overview

This repository is a dedicated project focused on architecting a professional **Internal Developer Platform (IDP)**. By leveraging the power of **Argo Workflows**, the platform enables developers to provision and manage services through intuitive **self-service operations**, reducing cognitive load and accelerating delivery.

### 💡 Featured Golden Path: Automated Database Provisioning
The platform features a fully-fledged **Database Provisioning** pipeline designed for on-premise **PostgreSQL** deployment. With a single self-service action, developers can spin up isolated database environments. The automated pipeline handles:
* **Security & Compliance:** Runs vulnerability scanning (Trivy) before deployment.
* **Automated Credentials:** Generates cryptographically secure, randomized secrets dynamically.
* **Instant Developer Onboarding:** Generates a developer "Access Card" (PDF) complete with pre-configured connection strings and ready-to-use boilerplate code snippets (e.g., Python).

The platform is under **active daily development**, continuously evolving with new features, security enhancements, and industry best practices..

---

## 📖 Table of Contents
1. [⚙️ Setup & Installation](#️-setup--installation)
2. [📦 Internal Developer Platform (Argo Workflows)](#-internal-developer-platform-argo-workflows)
3. [🔄 GitOps & Continuous Delivery (ArgoCD)](#-gitops--continuous-delivery-argocd)
4. [🛡️ DevSecOps & Security (CI/CD)](#-devsecops--security-cicd)
5. [🏗️ Infrastructure as Code (Terraform & LocalStack)](#-infrastructure-as-code-terraform--localstack)
6. [🌐 Networking & Observability (Cilium & Hubble)](#-networking--observability-cilium--hubble)
7. [📊 Monitoring & Metrics (Prometheus & Grafana)](#-monitoring--metrics-prometheus--grafana)
8. [🔑 Secrets Management (Sealed Secrets)](#-secrets-management-sealed-secrets)
9. [🚀 Apps & Base Implementation](#-apps--base-implementation)
10. [🚦 Local Access & Requirements](#-local-access--requirements)
11. [🛠️ Troubleshooting](#-troubleshooting)
12. [📂 Repository Structure](#-repository-structure)
13. [🤝 Contributing](#-contributing)
14. [🔮 Future Improvements](#-future-improvements)

---
## ⚙️ Setup & Installation

### 📋 System Requirements

| Requirement | Specification |
|:--|:--|
| **Memory** | Minimum 16 GB RAM |
| **Operating System** | Windows (Recommended) |
| **Alternative OS** | Linux (Supported with minor modifications) |

---

Follow the steps below to set up the local Kubernetes environment.

---

## Step 1 — Install Prerequisites

### Install Make

`make` is required to run the setup commands.

### Windows

Install GNU Make using `winget`:

```powershell
winget install GnuWin32.Make
```

Then add `make` to your PowerShell profile:

```powershell
Set-Alias -Name make -Value "C:\Program Files (x86)\GnuWin32\bin\make.exe"
```

### Linux

Install `make` if it is not already installed:

```bash
# Debian / Ubuntu
sudo apt-get install make

# CentOS / RHEL
sudo yum install make
```

---

## Step 2 — Install Docker Desktop

Download and install Docker Desktop:

- https://www.docker.com/products/docker-desktop

After installation:

1. Start Docker Desktop
2. Verify Docker is running before continuing
3. Create a cluster

---

## Step 3 — Create the Kubernetes Cluster

Navigate to the project root directory and run:

```bash
make cluster
```

This command installs:

- Kubernetes Cluster
- Argo Workflows
- ArgoCD
- Nginx Ingress
- Root Application

### Expected Setup Time

| Task | Duration |
|:--|:--|
| Cluster initialization | 3–4 minutes |
| Pod startup & stabilization | ~5 minutes |
| Total | 8–10 minutes |

---

## Step 4 — Configure LocalStack API

Run the following command using your LocalStack token:

```bash
make localstack-api TOKEN="your-token-here"
```

Generate your token from:

- https://app.localstack.cloud/

```bash
make localstack-bucket-password
```

It stores the S3 bucket credentials as a Kubernetes Secret


---

## Step 5 — Create the S3 Bucket

Provision the AWS S3 bucket:

```bash
make terraform-bucket
```

---

## Step 6 — Configure Local Hostnames

Add the following entries to your hosts file.

### Hosts File Locations

| OS | Path |
|:--|:--|
| Windows | `C:\Windows\System32\drivers\etc\hosts` |
| Linux / macOS | `/etc/hosts` |

### Add These Entries

```text
127.0.0.1 localstack.local
127.0.0.1 grafana.local
127.0.0.1 argocd.local
127.0.0.1 hubble.local
127.0.0.1 kubecost.local
127.0.0.1 velero.local
127.0.0.1 workflows.local
127.0.0.1 vault.local
127.0.0.1 postgres.local
```

---

## Step 7 — Retrieve Credentials

Use the following commands to retrieve access credentials.

| Component | Command |
|:--|:--|
| Argo Workflows | `make argo-password` |
| Grafana | `make grafana-password` |
| Velero | `make velero-auth` |
| Vault | `make vault-password` |

> The `vault-password` command returns both Vault seals and the access token.

---

## Step 8 — Verify Cluster Status

Check that all pods are running correctly:

```bash
kubectl get pods -A
```

---

## Step 9 — Access Platform Services

| Service | URL |
|:--|:--|
| Argo Workflows | http://workflows.local |
| ArgoCD | https://argocd.local |
| Grafana | http://grafana.local |
| Vault | http://vault.local |
| Hubble UI | http://hubble.local |
| Velero | http://velero.local |
| LocalStack | http://localstack.local |

---
## Step 10 — Submit the PostgreSQL Workflow

Open the Argo Workflows UI:

- http://workflows.local

### Update the Workflow Configuration

Before submitting the workflow, replace the existing IP address with your local machine IP.

Update the IP address on:

- Line 9
- Line 186

Use your local IP address (example: `192.168.1.28`).

---

### Submit the Workflow

1. Navigate to the **Workflows** section
2. Click **Submit New Workflow**
3. Upload the `postgres-deploy-pipeline` workflow file
4. Click **Submit**

### Verify Workflow Execution

Check that the workflow starts successfully and reaches the `Succeeded` state.
---
## Step 11 — Download the Reports

Run the following command to download the generated reports:

```bash
make download-report
```

### Report Location

The reports will be downloaded automatically to:

```text
D:/reports
```

# Troubleshooting

## Services Are Not Accessible

### Check Pod Status

```bash
kubectl get pods -A
```

### View Pod Logs

```bash
kubectl logs -n <namespace> <pod-name>
```

### Argo Is Not Accessible (404 error)

```bash
make ingress
```

Then, just do a hard refresh to see the apps.

### Test DNS Resolution

```bash
nslookup workflows.local
```

### Verify Hosts File

Ensure all host entries were added correctly.

### Restart Docker Desktop

1. Stop Docker Desktop
2. Start Docker Desktop again

---

## Out of Memory Errors

Increase Docker Desktop memory allocation:

1. Open Docker Desktop
2. Go to **Settings**
3. Open **Resources**
4. Increase memory to **16 GB or higher**

---
## 📦 Internal Developer Platform (Argo Workflows & Port)
* **Argo Workflows:** The central orchestration engine for managing service and infrastructure lifecycles through Kubernetes-native workflows.
* **Port Integration:** Advanced software catalog and scorecard system where Argo Workflows act as the execution layer to populate and update Port entities.
* **Self-Service Actions:** Every self-service action is backed by pre-defined Argo Workflow Templates, ensuring standardized, repeatable, and secure execution of operational tasks.

## 🔄 GitOps & Continuous Delivery (ArgoCD)
* **App-of-Apps Pattern:** A **Root-App** (found in `/bootstrap`) recursively manages all platform components within the `/infrastructure` directory.
* **Component-Based Delivery:** Each service (Cilium, Redis, Postgres, Monitoring etc) is deployed as a standalone ArgoCD `Application`.
* **Sync Policies:** Automated pruning and self-healing are enabled to prevent configuration drift.

## 🛡️ DevSecOps & Security (CI/CD)
* **Security Scanning:** Image security scanning is integrated directly within the workflow execution.
* **Automated Pipelines:** (Future Roadmap) Integration of **Semgrep** (SAST) and **Checkov** (IaC) for comprehensive code and infrastructure analysis.
* **Trivy:** Utilized for scanning container images and configurations for vulnerabilities.
* **GitHub Integration:** Security scan results are uploaded in SARIF format to the GitHub Security tab for centralized visibility.

## 🏗️ Infrastructure as Code (Terraform & LocalStack)
* **Terraform:** Modular IaC for cloud resource provisioning.
* **LocalStack (Free Version):** Emulates core AWS services (S3, SQS, Lambda, SNS, DynamoDB) locally within the cluster for cost-effective development.
* **Ingress:** Accessible via `localstack.local` with wildcard support (`*.localstack.local`).

## 🌐 Networking & Observability (Cilium & Hubble)
* **Cilium:** eBPF-powered networking and security.
* **Hubble UI:** Deep network flow observability accessible at `hubble.local`.

## 📊 Monitoring, Metrics & Logging (The Observability Stack)
* **Kube-Prometheus-Stack:** Lightweight setup with 1h retention and disabled webhooks for local development performance.
* **Grafana:** Centralized dashboards for metrics and logs.
* **Loki:** Log aggregation system, providing full-stack visibility alongside Prometheus metrics.

## 💾 Disaster Recovery & Backup (Velero)
* **Velero:** Automated backup and restore solution for Kubernetes cluster resources and persistent volumes.
* **Scheduled Backups:** Configured to ensure data resilience for PostgreSQL and Redis workloads.

## 💸 FinOps & Cost Optimization (Kubecost)
* **Kubecost:** Real-time cost visibility and insights for Kubernetes resources.
* **Resource Efficiency:** Helps identify over-provisioned workloads and optimize the platform's spend.

## 🔑 Secrets Management (Vault & ESO)
* **HashiCorp Vault:** Centralized secure storage and management of sensitive data (Single Source of Truth).
* **External Secrets Operator (ESO):** Automatically syncs secrets from Vault to Kubernetes, keeping the GitOps workflow secure and credential-free.

---
## 📂 Repository Structure

| Directory | Contents |
| :--- | :--- |
| `bootstrap/` | ArgoCD Root-App (Platform Entry Point) |
| `infrastructure/` | ArgoCD Apps for core cluster components, monitoring, LocalStack, database deployment pipelines, etc. |
| `terraform/` | IaC modules for Cloud & LocalStack provisioning |

---

## 🤝 Contributing
Contributions, ideas, and bug fixes are highly welcome! If you want to help improve this platform, please feel free to open an Issue or submit a Pull Request on GitHub.

---

## 🔮 Future Improvements

* **🤖 MLOps/AIOps:** Introduce specialized stacks tailored for MLOps/AIOps workflows.
* **🔀 Migration to Kubernetes Gateway API:** Transition from traditional Ingress to the modern Gateway API.
* **🚀 Progressive Delivery:** Integrate **Argo Rollouts** for Canary and Blue-Green deployments.
* **🔐 Enterprise Secret Management:** Migrate sensitive credentials from native Kubernetes Secrets to **HashiCorp Vault** for centralized, secure token management and dynamic rotation.
* **⚡ Event-Driven CI/CD Hooks:** Implement **Argo Events** to trigger specialized, security-compliant pipelines on every code push or pull request.
* **🧠 Predictive AI Agent:** Integrate an intelligent AI Agent to proactively predict infrastructure anomalies, forecast potential bottlenecks, and suggest automated remediation scripts.
* **💾 Automated Backups:** Enable automatic backups when a pod is created, ensuring data is safely persisted without manual intervention.
