
# Azure Kubernetes Service (AKS) & Infrastructure via Terraform

This repository provisions an enterprise-grade, modular, and multi-environment infrastructure on Microsoft Azure using **Terraform** and **GitHub Actions**. It deploys an **Azure Kubernetes Service (AKS)** cluster, **Azure Container Registry (ACR)**, and custom **Virtual Network (VNet)** infrastructure across isolated environments (`dev` and `prod`).

---

## 🏗 Repository Structure

```text
gcp-to-azure-aks/
├── .github/
│   └── workflows/
│       ├── terraform-lint.yml    # Runs fmt, TFLint, and Checkov static security analysis
│       └── terraform-deploy.yml  # Executes Plan on PR and Apply on merge to main via OIDC
├── modules/                      # Reusable infrastructure blueprints
│   ├── network/                  # VNet, Subnet, and Network Security rules
│   ├── acr/                      # Azure Container Registry (Standard/Premium SKUs)
│   └── aks/                      # Managed Identity, Subnet RBAC, AcrPull, & AKS Cluster
├── environments/
│   ├── dev/                      # Development environment configuration
│   │   ├── backend.tf            # Azure Blob Storage remote state config
│   │   ├── main.tf               # Module invocations for Dev
│   │   ├── terraform.tfvars      # Environment-specific variables
│   │   └── outputs.tf            # Connection strings & metadata
│   └── prod/                     # Production environment configuration
│       ├── backend.tf            # Production remote state config
│       ├── main.tf               # Module invocations for Prod
│       ├── terraform.tfvars      # Production-grade sizing & tags
│       └── outputs.tf
├── .gitignore                    # Excludes secrets, .terraform folders, and state files
├── .tflint.hcl                   # TFLint configuration with AzureRM ruleset
└── README.md
```

---

## 📐 Architecture Overview

All resources are deployed into an existing target Azure Resource Group (**`rg-andrei`**).

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ Azure Subscription                                                          │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Resource Group: rg-andrei                                            │  │
│  │                                                                       │  │
│  │  ┌──────────────────────┐        ┌─────────────────────────────────┐ │  │
│  │  │ Virtual Network      │        │ Azure Container Registry (ACR)  │ │  │
│  │  │ (vnet-andrei-dev)    │        │ (crandreiaksdev2026)            │ │  │
│  │  │  ┌─────────────────┐ │        └────────────────┬────────────────┘ │  │
│  │  │  │ Subnet: aks     │ │                         │ (AcrPull)        │  │
│  │  │  │ (10.0.1.0/24)    │ │                         ▼                  │  │
│  │  │  └────────┬────────┘ │        ┌─────────────────────────────────┐ │  │
│  │  │  └────────┼──────────┘        │ User-Assigned Identity          │ │  │
│  │              │                   │ (Network Contributor + AcrPull) │ │  │
│  │              │                   └────────────────┬────────────────┘ │  │
│  │              │                                    │                  │  │
│  │              ▼                                    ▼                  │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐ │  │
│  │  │ Azure Kubernetes Service (aks-andrei-dev)                       │ │  │
│  │  │  ├─ Network Plugin: Azure CNI                                   │ │  │
│  │  │  ├─ Service CIDR: 10.2.0.0/16 (Non-overlapping with VNet)       │ │  │
│  │  │  ├─ System Node Pool (Auto-scaling: 1 to 3 nodes)               │ │  │
│  │  │  └─ Workload Identity & OIDC Issuer Enabled                     │ │  │
│  │  └─────────────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘

```

---

## ⚙️ Environment Specifications

| Feature / Setting             | Development (`dev`)                 | Production (`prod`)                             |
| ----------------------------- | ------------------------------------- | ------------------------------------------------- |
| **Cluster Name**        | `aks-andrei-dev`                    | `aks-andrei-prod`                               |
| **VNet CIDR**           | `10.0.0.0/16`                       | `10.10.0.0/16`                                  |
| **Subnet CIDR**         | `10.0.1.0/24`                       | `10.10.1.0/24`                                  |
| **Service CIDR**        | `10.2.0.0/16`                       | `10.20.0.0/16`                                  |
| **Node VM Size**        | `Standard_D2s_v5` (2 vCPU, 8GB RAM) | `Standard_D4s_v5` (4 vCPU, 16GB RAM)            |
| **Auto-scaling Bounds** | Min: 1 / Max: 3                       | Min: 3 / Max: 10                                  |
| **ACR SKU**             | `Standard`                          | `Premium` (Zone Redundancy & Private Endpoints) |

---

## 🔒 Security & Key Architectural Highlights

1. **Pre-Existing Resource Group:** Configured via `data "azurerm_resource_group"` to ensure infrastructure deployments integrate smoothly into governed Azure environments (`rg-andrei`).
2. **Zero Hardcoded Credentials (Keyless OIDC):**

* **GitHub Actions:** Authenticates to Azure using **OpenID Connect (OIDC)** federated identities, eliminating long-lived client secrets.
* **AKS Identity:** Uses a dedicated User-Assigned Managed Identity (`id-aks-*`) assigned **Network Contributor** on the subnet and **AcrPull** on the Container Registry. No manual `imagePullSecrets` are needed in Kubernetes manifests.

3. **Non-Overlapping Network Topology:** Internal Kubernetes Service CIDRs (`10.2.0.0/16` in Dev, `10.20.0.0/16` in Prod) are explicitly segregated from VNet ranges to avoid IP collision errors (`ServiceCidrOverlapExistingSubnetsCidr`).
4. **Workload Identity Enabled:** Pods can inherit Azure Managed Identities directly via native OIDC annotations for secure keyless access to Azure Key Vault, Storage, or Azure SQL.

---

## 🤖 CI/CD Pipeline (GitHub Actions)

### 1. `terraform-lint.yml` (Pull Requests)

Automatically runs static analysis on every pull request targeting `main`:

* **Formatting Check:** Enforces standard code structure (`terraform fmt -check`).
* **Static Analysis:** Runs **TFLint** with the official `azurerm` ruleset module.
* **Security Scanning:** Scans for misconfigurations using **Checkov**.

### 2. `terraform-deploy.yml` (PR & Branch Merge)

* **On PR Open/Update:** Executes `terraform init`, `validate`, and `plan` across environments using a matrix build strategy.
* **On Merge to `main`:** Runs `terraform apply -auto-approve` using the generated `tfplan` artifact.

### Required GitHub Secrets

To enable GitHub Actions deployment via OIDC, configure the following secrets under **Settings ➔ Secrets and variables ➔ Actions**:

| Secret Name               | Description                                                             |
| ------------------------- | ----------------------------------------------------------------------- |
| `AZURE_CLIENT_ID`       | Application (Client) ID of the Azure App Registration                   |
| `AZURE_TENANT_ID`       | Azure Active Directory Tenant ID                                        |
| `AZURE_SUBSCRIPTION_ID` | Target Azure Subscription ID (`c6a76d9c-0f67-4a42-b2a1-3defb05f2aae`) |

---

## 🚀 Local Deployment Quickstart

### Prerequisites

Ensure the following tools are installed locally:

* [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.3.0)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (>= 2.50.0)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)

### Step 1: Authenticate to Azure

```bash
az login
az account set --subscription "c6a76d9c-0f67-4a42-b2a1-3defb05f2aae"

```

### Step 2: Choose and Deploy an Environment

Navigate to the target environment directory:

```bash
cd environments/dev

```

Initialize modules and remote backend state:

```bash
terraform init

```

Review the deployment execution plan:

```bash
terraform plan

```

Apply the changes:

```bash
terraform apply -auto-approve

```

### Step 3: Connect to the Kubernetes Cluster

Retrieve the cluster credentials into your local `~/.kube/config`:

```bash
# For Dev Environment
az aks get-credentials --resource-group rg-andrei --name aks-andrei-dev

# Verify connection
kubectl get nodes -o wide

```

### Step 4: Authenticate to Container Registry (ACR)

```bash
az acr login --name crandreiaksdev2026

```

---

## 🧹 Infrastructure Teardown

To tear down the cluster, networking, and registry resources without affecting the pre-existing Resource Group (`rg-andrei`):

```bash
cd environments/dev
terraform destroy -auto-approve

```

```

```
